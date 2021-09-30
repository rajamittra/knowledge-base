import paramiko, os, datetime, io, pytz, datetime

from steps.abotbdd.util import config, logger, pmulti_processor
from steps.abotbdd.data.cache import ssh_cache, base_cache
from steps.abotbdd.util.pexceptions import ABotException
from steps.abotbdd.data.cache import ssh_cache
from steps.abotbdd.data import constants, epc_constants, ssh_constants
from steps.abotbdd.service import mongo_service, base_service
import time
import re

capture_started_nodes = []
this_feature_start_time = None
data_client_node_password = {}
sut_node_password = {}
sut_pcap_node_password = {}
sut_log_node_password = {}

def get_ssh_user(node):
    user = None
    user_key = str(node) + '.' + constants.ABOT_SECURE_SHELL_USERNAME_KEY
    user = config.abot_get_str(user_key)
    if user is None:
        raise ABotException("Username {} not specified for node {}".format(str(user_key), str(node)))

    return user


def get_ssh_keyfile_and_passwd(node):
    keyfile = None
    password = None
    password_key = str(node) + '.' + constants.ABOT_SECURE_SHELL_PASSWORD_KEY
    password = config.abot_get_str(password_key)
    keyfile_key = str(node) + '.' + constants.ABOT_SECURE_SHELL_KEYFILE_KEY
    keyfile = config.abot_get_str(keyfile_key)
    if keyfile is None and password is None:
            raise ABotException("Neither Key File {} nor Password {} specified for node {} ...[ABORTING]".format(str(keyfile_key), str(password_key), str(node)))

    return keyfile, password

def is_ssh_enabled(node):
    ssh_is_enabled_key = node + '.' + constants.ABOT_SECURE_SHELL_IS_ENABLED_KEY
    ssh_is_enabled = config.abot_get_boolean(ssh_is_enabled_key)

    if ssh_is_enabled:
        if not ssh_is_enabled:
            logger.log().info("SSH --> {} ...[DISABLED]".format(str(node)))
            return False 
    else:
        logger.log().info("SSH -->  {} ...[DISABLED]".format(str(node)))
        return False

    return True


def ssh_connect(node):
    
    global sut_node_password  

    ssh_constants.SSH_CURRENT_NODE = node

    if node is not 'ABOT':
        if not is_ssh_enabled(node):
            return
        
    ip = mongo_service.abot_mongo_get_node_ip_from_db(node)

    try:
        user = get_ssh_user(node)
        keyfile, password = get_ssh_keyfile_and_passwd(node)

        sut_node_password[node] = password
        
        ssh_cache.SSH_CONN[node] = paramiko.SSHClient()
        ssh_cache.SSH_CONN[node].set_missing_host_key_policy(paramiko.AutoAddPolicy())

        logger.log().debug("SSH --> Node {} {}@{} (Keyfile={} password={})...[CONNECTING]".format(str(node), str(user), str(ip), str(keyfile), str(password)))

        if password is not None:
            ssh_cache.SSH_CONN[node].connect(ip, username=user, password=password, timeout=2)            
        elif keyfile is not None:
            ssh_cache.SSH_CONN[node].connect(ip, username=user, key_filename=keyfile, timeout=2)
            
        logger.log().info("SSH --> Node {} {}@{} (Keyfile={} password={})...[CONNECTED]".format(str(node), str(user), str(ip), str(keyfile), str(password)))

        ssh_cache.SSH_CONN_SUCCESS.append(node)

    except Exception as e:
        logger.log().warning("SSH --> Node {} ...[CONNECT FAILURE]".format(str(node)))


def ssh_disconnect(node):

    ssh_cache.SSH_CURRENT_NODE = node

    if not is_ssh_enabled(node):
        return

    try:
        ssh_cache.SSH_CONN[node].close()
        logger.log().info("SSH --> {} ...[DISCONNECTED]".format(str(node)))
    except Exception as e:
        logger.log().warning("SSH --> Node {} ...[DISCONNECT FAILURE]".format(str(node)))
        

def abot_execute_command(node, command):
    
    global sut_node_password

    ssh_cache.SSH_CURRENT_NODE = node
    ssh_cache.EXE_CMD_STDOUT[node] = ''
    ssh_cache.EXE_CMD_STDERR[node] = ''
                             
    logger.log().debug("SSH CMD on Node - {} {}...[EXECUTING]".format(str(node), str(command)))
    (stdin, stdout, stderr) = ('', '', '')
    try:

        stdin, stdout, stderr = ssh_cache.SSH_CONN[node].exec_command(command.replace('"', ''), timeout=25, get_pty=True)
        output = stdout.read().splitlines()
        
        if sut_node_password[node] is not None:
            stdin.write(sut_node_password[node] + '\n')
            stdin.flush()
        
        if output:
            ssh_cache.EXE_CMD_STDOUT[node] = output[0]
        logger.log().debug("SSH CMD on Node {} {}...[SUCCESS]".format(str(node), str(command)))
    except paramiko.SSHException:
        ssh_cache.EXE_CMD_STDERR[node] = (stderr.read().splitlines)[0]
        logger.log().debug("SSH CMD on Node - {} {}...[FAILED]".format(str(node), str(command)))


def abot_execute_powertop_command(node, command):
    try:
        (stdin, stdout, stderr) = ('', '', '')
        stdin, stdout, stderr = ssh_cache.SSH_CONN[node].exec_command(command.replace('"', ''), timeout=25, get_pty=False)
        stdout.readlines()
    except paramiko.SSHException as e:
        logger.log().debug("SSH POWERMON CMD on Node - {} {}...[FAILED]".format(str(node), str(e)))
    
def abot_assert_ssh(node):
    try:
        sut_list = config.abot_get_str(constants.ABOT_SUT_NAMES).split(',')
    except:
        sut_list = []
    
    if node in sut_list and node not in ssh_cache.SSH_CONN_SUCCESS:    
        base_cache.feature_error_cause = "SSH connection not available"
        raise ABotException(constants.ABOT_KNOWN_PATTERN + "SSH connection not available")

def abot_check_grammar_and_store_result(parameter, value):
    result = None
    if ssh_cache.EXE_CMD_STDOUT[ssh_cache.SSH_CURRENT_NODE] != '':
        result = re.search(parameter, ssh_cache.EXE_CMD_STDOUT[ssh_cache.SSH_CURRENT_NODE].decode('utf-8'))
    elif ssh_cache.EXE_CMD_STDERR[ssh_cache.SSH_CURRENT_NODE] != '':
        result = re.search(parameter, ssh_cache.EXE_CMD_STDERR[ssh_cache.SSH_CURRENT_NODE].decode('utf-8'))

    if result:
        if value.startswith("abotvar."):
            value_key = value.split('.', 1)[1]
            ssh_cache.EXE_VAR_STORE[value_key] = result.group(0)
        else:
            logger.log().warn("Unable to store variable in FF cache as the variable doesn't follow abotvar. prefix")
        
def abot_verify_stored_result(responseResult, existence):
    if responseResult.startswith(constants.ABOT_VAR):
        varResponseResult = responseResult.split('.', 1)[1].split('}')[0]

        if ssh_cache.EXE_VAR_STORE[varResponseResult] is None:
            raise ABotException("Unrecognized variable {}".format(str(responseResult)))
        
        if not process_ssh_response(ssh_cache.EXE_VAR_STORE[varResponseResult], existence):
            raise ABotException("Validation {} {} ...[FAILED]".format(str(responseResult), str(existence)))
    else:
        if not process_ssh_response(responseResult, existence):
            raise ABotException("Validation {} {} ...[FAILED]".format(str(responseResult), str(existence)))

        
def abot_execute_command_waiting_mode(node, command):

    ssh_cache.SSH_CURRENT_NODE = node
    ssh_cache.EXE_CMD_STDOUT[node] = ''
    ssh_cache.EXE_CMD_STDERR[node] = ''

    try:
        ssh_transp = ssh_cache.SSH_CONN[node].get_transport()
        chan = ssh_transp.open_session()
        chan.setblocking(0)
    except Exception as e:
       logger.log().warning("SSH CONNECTION ERROR for Node - {}...[NOT ESTABLISHED]".format(str(node)))
    (stdin, stdout, stderr) = ('','','')
    try:
        logger.log().debug("SSH CMD on Node - {} {}...[EXECUTING]".format(str(node), str(command)))
        stdin, stdout, stderr = ssh_cache.SSH_CONN[node].exec_command(command.replace('"', ''), timeout = 25, get_pty=True)
        exit_status = stdout.channel.recv_exit_status()
        output = stdout.read().splitlines()
        if output:
            ssh_cache.EXE_CMD_STDOUT[node] = output[0]
        logger.log().info("SSH CMD on Node {} {}...[SUCCESS]".format(str(node), str(command)))
    except paramiko.SSHException:
        ssh_cache.EXE_CMD_STDERR[node] = (stderr.read().splitlines)[0]
        logger.log().warning("SSH CMD on Node - {} {}...[FAILED]".format(str(node), str(command)))


def process_ssh_response(responseResult, existence):
    response = None
    if ssh_cache.EXE_VAR_STORE[constants.ABOT_SSH_RESPONSE] != '':
        response = ssh_cache.EXE_VAR_STORE[constants.ABOT_SSH_RESPONSE]

    if response:
        if existence == ssh_constants.STRING_NOCASE_PRESENT or existence == ssh_constants.STRING_NOCASE_CONTAINS:
            return re.search(responseResult.lower(), response.lower())
        if existence == ssh_constants.STRING_PRESENT or existence == ssh_constants.STRING_CONTAINS:
            return re.search(responseResult, response)
        if existence == ssh_constants.STRING_NOCASE_ABSENT or existence == ssh_constants.STRING_NOCASE_NOTCONTAINS:
            return not re.search(responseResult.lower(), response.lower())
        if existence == ssh_constants.STRING_ABSENT or existence == ssh_constants.STRING_NOTCONTAINS:
            return not re.search(responseResult.lower(), response.lower())
        if ssh_constants.INTEGER_GT in existence or ssh_constants.FLOAT_GT in existence or ssh_constants.STRING_GT in existence:
            check_value = extract_check_value(existence)
            return (response > check_value)
        if ssh_constants.INTEGER_EQ in existence or ssh_constants.FLOAT_EQ in existence or ssh_constants.STRING_EQ in existence:
            check_value = extract_check_value(existence)
            return (response == check_value)
        if ssh_constants.INTEGER_NE in existence or ssh_constants.FLOAT_NE in existence or ssh_constants.STRING_NE in existence:
            check_value = extract_check_value(existence)
            return (response != check_value)
        if ssh_constants.INTEGER_GE in existence or ssh_constants.FLOAT_GE in existence or ssh_constants.STRING_GE in existence:
            check_value = extract_check_value(existence)
            return (response >= check_value)
        if ssh_constants.INTEGER_LE in existence or ssh_constants.FLOAT_LE in existence or ssh_constants.STRING_LE in existence:
            check_value = extract_check_value(existence)
            return (response <= check_value)
        if ssh_constants.INTEGER_LT in existence or ssh_constants.FLOAT_LT in existence or ssh_constants.STRING_LT in existence:
            check_value = extract_check_value(existence)
            return (response < check_value)
        if ssh_constants.STRING_NOCASE_GT in existence:
            check_value = extract_check_value_nocase(existence)
            return (response.lower() > check_value.lower())
        if ssh_constants.STRING_NOCASE_EQ in existence:
            check_value = extract_check_value_nocase(existence)
            return (response.lower() == check_value.lower())
        if ssh_constants.STRING_NOCASE_NE in existence:
            check_value = extract_check_value_nocase(existence)
            return (response.lower() != check_value.lower())
        if ssh_constants.STRING_NOCASE_GE in existence:
            check_value = extract_check_value_nocase(existence)
            return (response.lower() >= check_value.lower())
        if ssh_constants.STRING_NOCASE_LE in existence:
            check_value = extract_check_value_nocase(existence)
            return (response.lower() <= check_value.lower())
        if ssh_constants.STRING_NOCASE_LT in existence:
            check_value = extract_check_value_nocase(existence)
            return (response.lower() < check_value.lower())
        else:
            raise ABotException("Unknown validation macro - {}".format(str(existence)))
    else:
        raise ABotException("Empty SSH Response while validating against macro - {}".format(str(existence)))

def extract_check_value(key_value):
    last = ')'
    if 'integer' in key_value:
        end = key_value.index(last, 13)
        check_value = key_value[13:end]
        return check_value
    elif 'float' in key_value:
        end = key_value.index(last, 11)
        check_value = key_value[11:end]
        return check_value
    else:
        end = key_value.index(last, 12)
        check_value = key_value[12:end]
        return check_value


def extract_check_value_nocase(key_value):
    last = ')'
    end = key_value.index(last, 19)
    check_value = key_value[19:end]
    return check_value


def abot_ssh_nodes(opcode):
    simulator_nodes = config.abot_get_str(epc_constants.ABOT_SIMULATOR_NAMES)
    sut_nodes = config.abot_get_str(epc_constants.ABOT_SUT_NAMES)

    # Primary Interface
    if (opcode in ssh_constants.ABOT_SSH_OPCODE_CONNECT):
        ssh_connect('ABOT')
    elif (opcode in ssh_constants.ABOT_SSH_OPCODE_DISCONNECT):
        ssh_disconnect('ABOT')
    
    # Simulator Nodes
    if len([simulator_nodes.split(',')]) == 0:
        if (opcode in ssh_constants.ABOT_SSH_OPCODE_CONNECT):
            ssh_connect(simulator_nodes)
        elif (opcode in ssh_constants.ABOT_SSH_OPCODE_DISCONNECT):
            ssh_disconnect(simulator_nodes)
    else:
        for simulator_node in simulator_nodes.split(','):
            if (opcode in ssh_constants.ABOT_SSH_OPCODE_CONNECT):
                ssh_connect(simulator_node)
            elif (opcode in ssh_constants.ABOT_SSH_OPCODE_DISCONNECT):
                ssh_disconnect(simulator_node)

    # SUT Nodes
    if len([sut_nodes.split(',')]) == 0:
        if (opcode in ssh_constants.ABOT_SSH_OPCODE_CONNECT):
            ssh_connect(sut_nodes)
        elif (opcode in ssh_constants.ABOT_SSH_OPCODE_DISCONNECT):
            ssh_disconnect(sut_nodes)
    else:
        for sut_node in sut_nodes.split(','):
            if (opcode in ssh_constants.ABOT_SSH_OPCODE_CONNECT):
                ssh_connect(sut_node)
            elif (opcode in ssh_constants.ABOT_SSH_OPCODE_DISCONNECT):
                ssh_disconnect(sut_node)

def abot_ssh_node_is_simulator(node):
    simulator_nodes = config.abot_get_str(epc_constants.ABOT_SIMULATOR_NAMES)
    if len([simulator_nodes.split(',')]) == 0:
        if node == simulator_nodes:
            return True
    else:
        for simulator_node in simulator_nodes.split(','):
            if node == simulator_node:
                return True

    return False

def abot_connect_SUT_log_servers():  
    if not pmulti_processor.is_parent_process():
        return

    global sut_log_node_password
    sut_names = config.abot_get_str(constants.ABOT_SUT_NAMES)
    sut_list = []
    if sut_names is not '':
        try:
            sut_list = sut_names.split(',')
        except:
            sut_list.append(sut_names)
    else:
        return
    
    for node in sut_list:
        password = None
        if config.abot_get_boolean(node + '.' + constants.LOG_EXTRACTION_IS_ENABLED):
            try:   
                user = config.abot_get_str(node + '.' + constants.LOG_EXTRACTION_USERNAME)
                keyfile = config.abot_get_str(node + '.' + constants.ABOT_SECURE_SHELL_KEYFILE_KEY)
                ip = config.abot_get_str(node + '.' + constants.LOG_EXTRACTION_IPADDRESS)
                password = config.abot_get_str(node + '.' + constants.ABOT_SECURE_SHELL_PASSWORD_KEY)
                sut_log_node_password[node] = password
                if user is None or ip is None:
                    return
                if keyfile is None and password is None:
                    return
                ssh_cache.SSH_SUT_LOG_SERVER_CONN[node]= paramiko.SSHClient()
                ssh_cache.SSH_SUT_LOG_SERVER_CONN[node].set_missing_host_key_policy(paramiko.AutoAddPolicy())
                
                if keyfile is not None:
                    ssh_cache.SSH_SUT_LOG_SERVER_CONN[node].connect(ip, username=user, key_filename=keyfile, timeout=2)
                else:
                    ssh_cache.SSH_SUT_LOG_SERVER_CONN[node].connect(ip, username=user, password=password, timeout=2)
                    
                logger.log().info("Log Server --> Node {}...[SSH CONNECTED]".format(str(node)))

                ssh_cache.SSH_LOG_SERVER_CONN_SUCCESS.append(node)

            except:
                logger.log().info("Log Server --> Node {}...[SSH CONNECT FAILURE]".format(str(node)))

          
def abot_extract_sut_logs_over_ssh(execution_start_time): 
    if not pmulti_processor.is_parent_process():
        return
    global sut_log_node_password
    sut_names = config.abot_get_str(constants.ABOT_SUT_NAMES)
    sut_list = []
    if sut_names is not '':
        try:
            sut_list = sut_names.split(',')
        except:
            sut_list.append(sut_names)
    else:
        return

    execution_end_time = datetime.datetime.now()
    for node in sut_list:
        try:
            if node in ssh_cache.SSH_LOG_SERVER_CONN_SUCCESS:
                sut_log_locations = []    
                try:
                        sut_log_locations = (config.abot_get_str(node + '.' + constants.LOG_EXTRACTION_WILDCARDS)).split(';')
                except:
                        sut_log_locations.append(config.abot_get_str(node + '.' + constants.LOG_EXTRACTION_WILDCARDS))
   
                for location in sut_log_locations:
                    download_location = constants.ABOT_LOG_DIR  + '/logs/sut-logs/' + config.abot_get_str(node + '.' + constants.VENDOR_TYPE) + '/' + node     
                    source_file_name = location.split('/')[-1]
                    if not os.path.exists(download_location):
                        os.makedirs(download_location) 
                    stdin, stdout, stderr = ssh_cache.SSH_SUT_LOG_SERVER_CONN[node].exec_command('sudo chmod 777 ' + location, get_pty=True)
                    if sut_log_node_password[node] is not None:
                        stdin.write(sut_log_node_password[node] + '\n')
                        stdin.flush()

                    ssh_cache.SSH_SUT_LOG_SERVER_CONN[node].open_sftp().get(location, download_location + '/' + source_file_name)
                    trim_sut_log(execution_start_time, execution_end_time, download_location + '/' + source_file_name, config.abot_get_str(node + '.' + constants.VENDOR_TYPE))     
        
        except Exception as e:
            if os.path.exists(download_location + '/' + source_file_name):
                    os.remove(download_location + '/' + source_file_name)
            logger.log().warning("Error while extracting " + source_file_name + "," + "ERROR:" + str(e))

def trim_sut_log(execution_start_time, execution_end_time, filePath, vendor_type):
    #trimmed_file_name = filePath.split('/')[-1] + '_dummy'
    #trimmed_file_location = '/'.join(filePath.split('/')[:-1]) + '/' + trimmed_file_name
    #common_datetime_pattern = '%m %d %H:%M:%S.%f'
    SUT_LOG_DATE_Patterns = []
    patterns = config.abot_get_str(constants.SUT_LOG_DATE_PATTERNS)
    try:
        SUT_LOG_DATE_Patterns = patterns.split(';')
    except:
        SUT_LOG_DATE_Patterns.append(patterns)

    with io.open(filePath, 'r', encoding='windows-1252') as f:
        log_lines = f.readlines()
        os.remove(filePath)
    with open(filePath, 'w+') as f:
        trimmed_log = []        
        for i in range(len(log_lines)-1, -1, -1):
            for pattern in SUT_LOG_DATE_Patterns:
                #search_pattern = next(iter(pattern))
                search_pattern = pattern.split(',')[0]
                #datetime_pattern = pattern[search_pattern]               
                datetime_pattern = pattern.split(',')[1].replace('\s', ' ').replace('%%', '%')
                if(re.search(search_pattern, log_lines[i])):
                    date_time_stamp = re.search(search_pattern, log_lines[i]).group(0)[:26]
                    try:
                        if not '%Y' in datetime_pattern:
                            date_time_stamp = str(execution_start_time.year) + '/' + date_time_stamp
                            date_time_stamp = datetime.datetime.strptime(date_time_stamp, '%Y/' + datetime_pattern)
                        else:
                            date_time_stamp = datetime.datetime.strptime(date_time_stamp, datetime_pattern)
                    #date_time_stamp = datetime.datetime.strftime(date_time_stamp, common_datetime_pattern)
                        if date_time_stamp >= execution_start_time:
                            trimmed_log.append(log_lines[i])
                    except Exception as e:
                        pass
                    break
        
        for i in range(len(trimmed_log)-1, -1, -1):
            f.write(str(trimmed_log[i]))


def abot_connect_SUT_pcap_servers():  

    if not pmulti_processor.is_parent_process():
        return

    global sut_pcap_node_password

    sut_list = base_service.abot_get_sut_list()
    if not sut_list:
        return
    
    for node in sut_list:
        if config.abot_get_boolean(node + '.' + constants.PCAP_EXTRACTION_IS_ENABLED) and config.abot_get_str(node + '.' + constants.PCAP_EXTRACTION_CMD):
            try:   
                user = config.abot_get_str(node + '.' + constants.PCAP_EXTRACTION_USERNAME)
                keyfile = config.abot_get_str(node + '.' + constants.ABOT_SECURE_SHELL_KEYFILE_KEY)
                ip = config.abot_get_str(node + '.' + constants.PCAP_EXTRACTION_IPADDRESS)
                password = config.abot_get_str(node + '.' + constants.ABOT_SECURE_SHELL_PASSWORD_KEY)
                sut_pcap_node_password[node] = password
                if user is None or ip is None:
                    return
                if keyfile is None and password is None:
                    return
                ssh_cache.SSH_SUT_PCAP_SERVER_CONN[node]= paramiko.SSHClient()
                ssh_cache.SSH_SUT_PCAP_SERVER_CONN[node].set_missing_host_key_policy(paramiko.AutoAddPolicy())
                
                if keyfile is not None:
                    ssh_cache.SSH_SUT_PCAP_SERVER_CONN[node].connect(ip, username=user, key_filename=keyfile, timeout=2)
                else:
                    ssh_cache.SSH_SUT_PCAP_SERVER_CONN[node].connect(ip, username=user, password=password, timeout=2)
                    
                logger.log().info("Pcap Server --> Node {}...[SSH CONNECTED]".format(str(node)))

                ssh_cache.SSH_PCAP_SERVER_CONN_SUCCESS.append(node)

            except:
                logger.log().info("PCAP Server --> Node {}...[SSH CONNECT FAILURE]".format(str(node)))
        

def abot_start_packet_capture_at_vendor_node(start_time):
    global capture_started_nodes
    global this_feature_start_time
    global sut_pcap_node_password

    this_feature_start_time = start_time
    
    sut_list = base_service.abot_get_sut_list()
    if not sut_list:
        return

    for node in sut_list:
        try:
            if config.abot_get_boolean(node + '.' + constants.PCAP_EXTRACTION_IS_ENABLED):
                if not config.abot_get_str(node + '.' + constants.PCAP_EXTRACTION_CMD):
                    logger.log().warning("Unable to start packet capture at node {}:command not specified".format(node))
                else:
                    if node in ssh_cache.SSH_PCAP_SERVER_CONN_SUCCESS:
                        try:
                            cmd = config.abot_get_str(node + '.' + constants.PCAP_EXTRACTION_CMD).split(';')[0]
                            stdin, stdout, stderr = ssh_cache.SSH_SUT_PCAP_SERVER_CONN[node].exec_command(cmd, get_pty=True)

                            if sut_pcap_node_password[node] is not None:
                                stdin.write(sut_pcap_node_password[node] + '\n')
                                stdin.flush()
                            
                            logger.log().info("Packet capture started at node {}".format(node))
                            capture_started_nodes.append(node)
                        except Exception as e:
                            logger.log().warning("Unable to start packet capture at node {}:command not proper".format(node))

        except:
            logger.log().warning("Unable to start packet capture at node {}".format(node))

def abot_stop_packet_capture_at_vendor_node():
    global capture_started_nodes
    if capture_started_nodes != []:
        time.sleep(2)
    for node in capture_started_nodes:
        try:
            cmd = config.abot_get_str(node + '.' + constants.PCAP_EXTRACTION_CMD).split(';')[1]
            stdin, stdout, stderr = ssh_cache.SSH_SUT_PCAP_SERVER_CONN[node].exec_command(cmd, get_pty=True)
            
            if sut_pcap_node_password[node] is not None:
                stdin.write(sut_pcap_node_password[node] + '\n')
                stdin.flush()
            
            logger.log().info("Packet capture stopped at node {}".format(node))
            force_kill_tcpdump(node)
        except:
            force_kill_tcpdump(node)

def force_kill_tcpdump(node):
    if config.abot_get_str(node + '.' + constants.PCAP_EXTRACTION_USERNAME) == 'root':
        stdin, stdout, stderr = ssh_cache.SSH_SUT_PCAP_SERVER_CONN[node].exec_command('pkill tcpdump', get_pty=True)

    else:
        stdin, stdout, stderr = ssh_cache.SSH_SUT_PCAP_SERVER_CONN[node].exec_command('sudo pkill tcpdump', get_pty=True)
    
    if sut_pcap_node_password[node] is not None:
        stdin.write(sut_pcap_node_password[node] + '\n')
        stdin.flush()


def abot_extract_sut_pcaps_over_ssh():
    global this_feature_start_time
    sut_list = base_service.abot_get_sut_list()
    if not sut_list:
        return
 
    for node in sut_list:
        sut_pcap_locations = []  
        try:
            if node in ssh_cache.SSH_PCAP_SERVER_CONN_SUCCESS:  
                try:
                    sut_pcap_locations = (config.abot_get_str(node + '.' + constants.PCAP_EXTRACTION_WILDCARDS)).split(';')
                except:
                    sut_pcap_locations.append(config.abot_get_str(node + '.' + constants.PCAP_EXTRACTION_WILDCARDS))

                for location in sut_pcap_locations:
                    download_location = constants.ABOT_LOG_DIR + base_cache.folder_name + '/' + constants.LOG_PCAP_LOCATION + '/sut-packets/'
                    if not os.path.exists(download_location):
                        os.makedirs(download_location)  
                    source_file_name = location.split('/')[-1].split('.pcap')[0] 
                    download_file_name = source_file_name + '_' + this_feature_start_time.replace(' ', '_').split('.')[0] + '_' + config.abot_get_str(node + '.' + constants.VENDOR_TYPE) + '_' + base_cache.current_feature_file_name.split('.feature')[0] + '.pcap'
                    if not os.path.exists(download_location):
                        os.makedirs(download_location) 
                    stdin, stdout, stderr = ssh_cache.SSH_SUT_PCAP_SERVER_CONN[node].exec_command('sudo chmod 777 ' + location)
                    if sut_pcap_node_password[node] is not None:
                        stdin.write(sut_pcap_node_password[node] + '\n')
                        stdin.flush()
                    ssh_cache.SSH_SUT_PCAP_SERVER_CONN[node].open_sftp().get(location, download_location + '/' + download_file_name)
                    #stdin, stdout, stderr = ssh_cache.SSH_SUT_PCAP_SERVER_CONN[node].exec_command('date')
                    #remote_timezone = stdout.readline().split(' ')[4]          
                    #trim_sut_pcap(download_location + '/' + source_file_name, node, remote_timezone)     
                    logger.log().debug("Successfully extracted pcap " + download_file_name)
        except Exception as e:
            if os.path.exists(download_location + '/' + download_file_name):
                    os.remove(download_location + '/' + download_file_name)
            logger.log().warning("Error while extracting " + download_file_name + "," + "ERROR:" + str(e))
        finally:
            if sut_pcap_locations:
                for location in sut_pcap_locations:
                    pcap_file_delete_command = 'rm -rf ' + location 
                    if config.abot_get_str(node + '.' + constants.PCAP_EXTRACTION_USERNAME) != 'root':
                        pcap_file_delete_command = 'sudo ' + pcap_file_delete_command
                    stdin, stdout, stderr = ssh_cache.SSH_SUT_PCAP_SERVER_CONN[node].exec_command(pcap_file_delete_command, get_pty = True)
                    if sut_pcap_node_password[node] is not None:
                        stdin.write(sut_pcap_node_password[node] + '\n')
                        stdin.flush()


def trim_sut_pcap(file, node, remote_timezone):
    for ff, time in base_cache.ff_execution_duration_details.items():
        pcap_path = constants.ABOT_LOG_DIR + '/' + constants.LOG_PCAP_LOCATION + '/sut-packets/' + ff
        if not os.path.exists(pcap_path):
            os.makedirs(pcap_path)
        pcap_file_name = file.split('/')[-1]
        
        if remote_timezone == 'UTC':
            start_time = time['start_time']
            end_time = time['end_time']
        else:
            start_time = convert_to_specific_timezone(time['start_time'], 'UTC', remote_timezone)
            end_time = convert_to_specific_timezone(time['end_time'], 'UTC', remote_timezone)
            
        command = 'editcap -A \"' + start_time + '\" -B \"' + end_time +'\" ' + file + ' ' + pcap_path + '/' + pcap_file_name
        os.system(command)
    
    os.remove(file)

def convert_to_specific_timezone(timestamp, from_timezone, to_timezone):
    old_timezone = pytz.timezone(from_timezone)
    new_timezone = pytz.timezone(to_timezone)
    timestamp = datetime.datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S.%f')
    new_timezone_timestamp = old_timezone.localize(timestamp).astimezone(new_timezone) 
    return str(new_timezone_timestamp)


def abot_connect_to_data_clients(client_info_dict):
    global data_client_node_password
    for client_name, client_info  in client_info_dict.items():
        try:   
            password = None
            user = config.abot_get_str(client_name + '.' + constants.ABOT_SECURE_SHELL_USERNAME_KEY)
            keyfile = config.abot_get_str(client_name + '.' + constants.ABOT_SECURE_SHELL_KEYFILE_KEY)
            ip = config.abot_get_str(client_name + '.' + constants.ABOT_SECURE_SHELL_IPADDRESS_KEY)
            password = config.abot_get_str(client_name + '.' + constants.ABOT_SECURE_SHELL_PASSWORD_KEY)
            data_client_node_password[client_name] = password
            if user is None or ip is None:
                return
            if keyfile is None and password is None:
                return
            
            ssh_cache.SSH_DATA_CLIENT_CONN[client_name] = paramiko.SSHClient()
            ssh_cache.SSH_DATA_CLIENT_CONN[client_name].set_missing_host_key_policy(paramiko.AutoAddPolicy())
            
            if keyfile is not None:
                ssh_cache.SSH_DATA_CLIENT_CONN[client_name].connect(ip, username=user, key_filename=keyfile, timeout=2)
            else:
                ssh_cache.SSH_DATA_CLIENT_CONN[client_name].connect(ip, username=user, password=password, timeout=2)
                
            logger.log().info("Client --> {}...[SSH CONNECTED]".format(str(client_name)))

            ssh_cache.SSH_DATA_CLIENT_CONN_SUCCESS.append(client_name)

        except Exception as e:
            logger.log().debug(e)
            logger.log().info("Client --> {}...[SSH CONNECT FAILURE]".format(str(client_name)))


def abot_start_data_clients(client_info_dict, client_type):
    global data_client_node_password
    if client_type == 'BROWSER_BASED_VIDEO_PLAYER':
        start_browser_based_players(client_info_dict)
    if client_type == 'FTP':
        start_ftp_clients(client_info_dict)
        

def start_browser_based_players(client_info_dict):
    for client_name, client_info  in client_info_dict.items():
        try:
            
            command = 'python ' + constants.DATA_CLIENT_CONF_LOCATION +'/play_video.py {} {} {}'.format(client_info['player_url'], client_info['duration'], client_info['file_name'])
            execute_ssh_command(client_name, command)
                
        except Exception as e:
            logger.log().debug(e)
            logger.log().info("Unable to start client {}".format(client_name))


def get_file_from_client_box(client_info_dict):
    try:
        for client_name, client_info  in client_info_dict.items():
            #command = 'sshpass -p ' + data_client_node_password[client_name] +' rsync -avz ' + config.abot_get_str(client_name + '.' + constants.VIDEO_CLIENT_SECURESHELL_USERNAME) + '@' + config.abot_get_str(client_name + '.' + constants.VIDEO_CLIENT_SECURESHELL_IP) + ':~/' + client_info['file_name'] + '.mp4 ' + 
            download_location = constants.ABOT_LOG_DIR + base_cache.folder_name + '/' + client_info['file_name'] + '.mp4 '
            file_location = constants.DATA_CLIENT_VIDEO_LOCATION + client_info['file_name'] + '.mp4 '
            ssh_cache.SSH_DATA_CLIENT_CONN[client_name].open_sftp().get(file_location.strip(), download_location.strip())

    except Exception as e:
        raise ABotException('File could not be downloaded from client box')


def start_ftp_clients(client_info_dict):
    for client_name, client_info  in client_info_dict.items():
        try:
            command = client_info['ftp_command']            
            execute_ssh_command(client_name, command)

        except Exception as e:
            logger.log().debug(e)
            logger.log().info("Unable to start client {}".format(client_name))

def execute_ssh_command(client_name, command):
    
    logger.log().info("Starting client {}".format(client_name))
    if not client_name in ssh_cache.SSH_DATA_CLIENT_CONN_SUCCESS:
        logger.log().debug("SSH Connection not available for Client {}".format(client_name))
        return
    logger.log().debug('SSH Command ---> ' + command)
    stdin,stdout,stderr = ssh_cache.SSH_DATA_CLIENT_CONN[client_name].exec_command(command, get_pty=True)

    if data_client_node_password[client_name] is not None:
        stdin.write(data_client_node_password[client_name] + '\n')
        stdin.flush()

    outlines=stdout.readlines()
    resp=''.join(outlines)
    logger.log().info("Client : {} resp ---> {}".format(client_name,resp))
    
    err = None
    outlines = stderr.readlines()
    err = ''.join(outlines)
    if not err:
        ssh_cache.SSH_DATA_CLIENT_START_SUCCESS.append(client_name)
