# importing the requests library
import requests
import json
import time
  
def is_executing(arg_ip):
    # api-endpoint
    URL = "http://{}:5000/abot/api/v5/execution_status".format(arg_ip)
    
    
    # sending get request and saving the response as response object
    r = requests.get(url = URL)
    
    # extracting data in json format
    data = r.json()
    
    
    # extracting latitude, longitude and formatted address 
    # of the first matching location
    status = data['status']

    return status

def execute_ff(arg_tags_list,arg_ip):
    # defining the api-endpoint 
    API_ENDPOINT = "http://{}:5000/abot/api/v5/feature_files/execute".format(arg_ip)   
   
    headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}
    
    for each_tag in arg_tags_list:
        # data to be sent to api
        data = {"params": each_tag}
        # sending post request and saving response as response object
        r = requests.post(url = API_ENDPOINT, data=json.dumps(data), headers=headers)
       
        # extracting response text 
        job_status = r.text

        print("Executing tag {} :{}".format(each_tag,job_status))

        while is_executing(arg_ip):
            time.sleep(5)
            print("wake up to check execution of tag {}..".format(each_tag))

    print("All tags are executed..")


def main():
    tags_list = ['23401-s1-setup-req-after-attach','initial-attach-test',
                '23401-s1-setup-failure-unknown-tac','23401-s1-setup-failure-supported-tas']
    api_ip_address = '192.168.40.106'
    execute_ff(tags_list,api_ip_address)

if __name__ == "__main__":
    main()


