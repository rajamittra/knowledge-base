@initial-attach-test @2-attach-procedure-for-eps-services @23401-4g

Feature: Attach procedure for EPS services

  Scenario: Initial Attach with IMSI and PDN Connectivity Request

    Given the steps below will be executed at the end
    When I run the SSH command {abotprop.SUT.DEFAULT.MME.CONFIG} at node MME1
    When I run the SSH command {abotprop.SUT.DEFAULT.ENB.CONFIG} at node eNodeB1
    When I run the SSH command {abotprop.SUT.DEFAULT.SGW.CONFIG} at node SGW1
    When I run the SSH command {abotprop.SUT.DEFAULT.PGW.CONFIG} at node PGW1
    When I run the SSH command {abotprop.SUT.DEFAULT.HSS.CONFIG} at node HSS1
    When I run the SSH command {abotprop.SUT.DEFAULT.PCRF.CONFIG} at node PCRF1
    Then the ending steps are complete

    Given the test data is in file /featureFiles/MESSAGE_BUNDLES/EPC_MESSAGES.xml

    When I run the SSH command {abotprop.SUT.CUSTOM.MME.CONFIG} and pause for {abotprop.WAIT_5_SEC} seconds at node MME1
    When I run the SSH command {abotprop.SUT.CUSTOM.ENB.CONFIG} and pause for {abotprop.WAIT_5_SEC} seconds at node eNodeB1
    When I run the SSH command {abotprop.SUT.CUSTOM.SGW.CONFIG} and pause for {abotprop.WAIT_5_SEC} seconds at node SGW1
    When I run the SSH command {abotprop.SUT.CUSTOM.PGW.CONFIG} and pause for {abotprop.WAIT_5_SEC} seconds at node PGW1
    When I run the SSH command {abotprop.SUT.CUSTOM.HSS.CONFIG} and pause for {abotprop.WAIT_5_SEC} seconds at node HSS1
    When I run the SSH command {abotprop.SUT.CUSTOM.PCRF.CONFIG} and pause for {abotprop.WAIT_5_SEC} seconds at node PCRF1

    Given all configured endpoints for EPC are connected successfully
    
    Given I setup load scenario on interface S1-MME,S5-S8,S11,S6A,GX with the following parameters:
      | parameter              | value                  |
      | switch                 | {abotprop.LOAD_SWITCH} |
      | call_model             | initial-attach         |
      | num_subscribers        | 50                     |
      | concurrency            | 10                     |
      | load_percentage_factor | 100                    |

    When I send DIAMETER message DIA_CAPABILITIES_EXCHANGE_REQUEST on interface GX with the following details from node PCRF1 to PGW1:
      | parameter                                          | value                                  |
      | Hop-by-Hop Identifier                              | 123                                    |
      | End-to-End Identifier                              | 456                                    |
      | Origin-Host                                        | {abotprop.SUT.GX.CAPEX.ORIGIN.HOST}    |
      | Origin-Realm                                       | {abotprop.SUT.GX.CAPEX.ORIGIN.REALM}   |
      | Origin-State-Id                                    | 1584110503                             |
      | Host-IP-Address                                    | {abotprop.SUT.GX.CAPEX.ORIGIN.HOST.IP} |
      | Vendor-Id                                          | 0                                      |
      | Product-Name                                       | freeDiameter                           |
      | Firmware-Revision                                  | 10200                                  |
      | Inband-Security-Id                                 | 0                                      |
      | Vendor-Specific-Application-Id.Vendor-Id           | {abotprop.SUT.3GPP.VENDOR.ID}          |
      | Vendor-Specific-Application-Id.Auth-Application-Id | {abotprop.SUT.3GPP.GX.APPID}           |
      | Supported-Vendor-Id                                | {abotprop.SUT.3GPP.VENDOR.ID}          |

    Then I receive and validate DIAMETER message DIA_CAPABILITIES_EXCHANGE_REQUEST on interface GX with the following details on node PGW1 from PCRF1:
      | parameter                                          | value                                               |
      | Hop-by-Hop Identifier                              | save(HOP_BY_HOP_ID)                                 |
      | End-to-End Identifier                              | save(END_TO_END_ID)                                 |
      | Origin-Host                                        | {string:eq}({abotprop.SUT.GX.CAPEX.ORIGIN.HOST})    |
      | Origin-Realm                                       | {string:eq}({abotprop.SUT.GX.CAPEX.ORIGIN.REALM})   |
      | Origin-State-Id                                    | {integer:eq}(1584110503)                            |
      | Host-IP-Address                                    | {string:eq}({abotprop.SUT.GX.CAPEX.ORIGIN.HOST.IP}) |
      | Vendor-Id                                          | {integer:eq}(0)                                     |
      | Product-Name                                       | {string:eq}(freeDiameter)                           |
      | Firmware-Revision                                  | {integer:eq}(10200)                                 |
      | Inband-Security-Id                                 | {integer:eq}(0)                                     |
      | Vendor-Specific-Application-Id.Vendor-Id           | {integer:eq}({abotprop.SUT.3GPP.VENDOR.ID})         |
      | Vendor-Specific-Application-Id.Auth-Application-Id | {integer:eq}({abotprop.SUT.3GPP.GX.APPID})          |
      | Supported-Vendor-Id                                | {integer:eq}({abotprop.SUT.3GPP.VENDOR.ID})         |

    When I send DIAMETER message DIA_CAPABILITIES_EXCHANGE_ANSWER on interface GX with the following details from node PGW1 to PCRF1:
      | parameter                                          | value                                  |
      | Hop-by-Hop Identifier                              | $(HOP_BY_HOP_ID)                       |
      | End-to-End Identifier                              | $(END_TO_END_ID)                       |
      | Result-Code                                        | {abotprop.SUT.3GPP.GX.DIA_RESULT_CODE} |
      | Origin-Host                                        | {abotprop.SUT.GX.CAPEX.DEST.HOST}      |
      | Origin-Realm                                       | {abotprop.SUT.GX.CAPEX.DEST.REALM}     |
      | Origin-State-Id                                    | 1584110486                             |
      | Host-IP-Address                                    | {abotprop.SUT.GX.CAPEX.DEST.HOST.IP}   |
      | Vendor-Id                                          | 0                                      |
      | Product-Name                                       | freeDiameter                           |
      | Firmware-Revision                                  | 10200                                  |
      | Inband-Security-Id                                 | 0                                      |
      | Vendor-Specific-Application-Id.Vendor-Id           | {abotprop.SUT.3GPP.VENDOR.ID}          |
      | Vendor-Specific-Application-Id.Auth-Application-Id | {abotprop.SUT.3GPP.GX.APPID}           |
      | Supported-Vendor-Id                                | {abotprop.SUT.3GPP.VENDOR.ID}          |

    Then I receive and validate DIAMETER message DIA_CAPABILITIES_EXCHANGE_ANSWER on interface GX with the following details on node PCRF1 from PGW1:
      | parameter                                          | value                                                |
      | Hop-by-Hop Identifier                              | save(HOP_BY_HOP_ID)                                  |
      | End-to-End Identifier                              | save(END_TO_END_ID)                                  |
      | Result-Code                                        | {integer:eq}({abotprop.SUT.3GPP.GX.DIA_RESULT_CODE}) |
      | Origin-Host                                        | {string:eq}({abotprop.SUT.GX.CAPEX.DEST.HOST})       |
      | Origin-Realm                                       | {string:eq}({abotprop.SUT.GX.CAPEX.DEST.REALM})      |
      | Origin-State-Id                                    | {integer:eq}(1584110486)                             |
      | Host-IP-Address                                    | {string:eq}({abotprop.SUT.GX.CAPEX.DEST.HOST.IP})    |
      | Vendor-Id                                          | {integer:eq}(0)                                      |
      | Product-Name                                       | {string:eq}(freeDiameter)                            |
      | Firmware-Revision                                  | {integer:eq}(10200)                                  |
      | Inband-Security-Id                                 | {integer:eq}(0)                                      |
      | Vendor-Specific-Application-Id.Vendor-Id           | {integer:eq}({abotprop.SUT.3GPP.VENDOR.ID})          |
      | Vendor-Specific-Application-Id.Auth-Application-Id | {integer:eq}({abotprop.SUT.3GPP.GX.APPID})           |
      | Supported-Vendor-Id                                | {integer:eq}({abotprop.SUT.3GPP.VENDOR.ID})          |

    When I send S1AP message S1_SETUP_REQ on interface S1-MME with the following details from node eNodeB1 to MME1:
      | parameter                                                | value                               |
      | global_enb_id.plmn_identity.mcc                          | {abotprop.SUT.MCC}                  |
      | global_enb_id.plmn_identity.mnc                          | {abotprop.SUT.MNC}                  |
      | global_enb_id.macro_enb_id                               | {abotprop.SUT.GLOBAL.MACRO.ENB1.ID} |
      | enb_name                                                 | {abotprop.SUT.ENB.NAME}             |
      | supported_tas_list.0.tac                                 | {abotprop.SUT.TAC}                  |
      | supported_tas_list.0.broadcast_plmns.0.plmn_identity.mcc | {abotprop.SUT.MCC}                  |
      | supported_tas_list.0.broadcast_plmns.0.plmn_identity.mnc | {abotprop.SUT.MNC}                  |
      | paging_drx                                               | {abotprop.SUT.PAGING.DRX}           |

    Then I receive and validate S1AP message S1_SETUP_REQ on interface S1-MME with the following details on node MME1 from eNodeB1:
      | parameter                                                | value                                            |
      | global_enb_id.plmn_identity.mcc                          | {integer:eq}({abotprop.SUT.MCC})                 |
      | global_enb_id.plmn_identity.mnc                          | {integer:eq}({abotprop.SUT.MNC})                 |
      | global_enb_id.macro_enb_id                               | {string:eq}({abotprop.SUT.GLOBAL.MACRO.ENB1.ID}) |
      | enb_name                                                 | {string:eq}({abotprop.SUT.ENB.NAME})             |
      | supported_tas_list.0.tac                                 | {integer:eq}({abotprop.SUT.TAC})                 |
      | supported_tas_list.0.broadcast_plmns.0.plmn_identity.mcc | {integer:eq}({abotprop.SUT.MCC})                 |
      | supported_tas_list.0.broadcast_plmns.0.plmn_identity.mnc | {integer:eq}({abotprop.SUT.MNC})                 |
      | paging_drx                                               | {string:eq}({abotprop.SUT.PAGING.DRX})           |

    When I send S1AP message S1_SETUP_RES on interface S1-MME with the following details from node MME1 to eNodeB1:
      | parameter                                              | value                                      |
      | served_gummeis_list.0.served_plmns.0.plmn_identity.mcc | {abotprop.SUT.MCC}                         |
      | served_gummeis_list.0.served_plmns.0.plmn_identity.mnc | {abotprop.SUT.MNC}                         |
      | served_gummeis_list.0.served_group_ids.0.mme_group_id  | {abotprop.SUT.MME.GROUP.ID}                |
      | served_gummeis_list.0.served_mmecs.0.mme_code          | {abotprop.SUT.MME.CODE}                    |
      | relative_mme_capacity                                  | {abotprop.SUT.RELATIVE.MME.CAPACITY}       |
      | mme_name                                               | {abotprop.SUT.MME.NAME}                    |
      | mme_relay_support_indicator                            | {abotprop.SUT.MME.RELAY.SUPPORT.INDICATOR} |

    Then I receive and validate S1AP message S1_SETUP_RES on interface S1-MME with the following details on node eNodeB1 from MME1:
      | parameter                                              | value                                                   |
      | served_gummeis_list.0.served_plmns.0.plmn_identity.mcc | {integer:eq}({abotprop.SUT.MCC})                        |
      | served_gummeis_list.0.served_plmns.0.plmn_identity.mnc | {integer:eq}({abotprop.SUT.MNC})                        |
      | served_gummeis_list.0.served_group_ids.0.mme_group_id  | save(MME_GROUP_ID)                                      |
      | served_gummeis_list.0.served_mmecs.0.mme_code          | {string:eq}({abotprop.SUT.MME.CODE})                    |
      | relative_mme_capacity                                  | save(RELATIVE_MME_CAPACITY)                             |
      | mme_name                                               | {string:eq}({abotprop.SUT.MME.NAME})                    |
      | mme_relay_support_indicator                            | {string:eq}({abotprop.SUT.MME.RELAY.SUPPORT.INDICATOR}) |

    When I send S1AP message S1_INIT_UE_MSG_NAS_ATTACH_REQ_PDN_CON_REQ on interface S1-MME with the following details from node eNodeB1 to MME1:
      | parameter                                                                        | value                                              |
      | enb_ue_s1ap_id                                                                   | incr(12697203,1)                                   |
      | nas_pdu.protocol_discriminator.emm                                               | {abotprop.SUT.NAS.PROTO.EMM}                       |
      | nas_pdu.security_header_type.plain                                               | {abotprop.SUT.NAS.SECURITY.HEAD.PLAIN}             |
      | nas_pdu.message_type.emm                                                         | {abotprop.SUT.NAS.ATTACH.REQ.MSG.EMM}              |
      | nas_pdu.attach_request.eps_attach_type                                           | {abotprop.SUT.NAS.ATTACH.REQ.EPS.ATTACH.TYPE}      |
      | nas_pdu.attach_request.type_of_security_context                                  | {abotprop.SUT.NAS.TYPE.OF.SEC.CTXT}                |
      | nas_pdu.attach_request.nas_key_set_identifier                                    | 7                                                  |
      | nas_pdu.attach_request.eps_mobile_identity.imsi                                  | incr({abotprop.SUT.IMSI.START1},1)                 |
      | nas_pdu.attach_request.ue_network_capability.eia                                 | {abotprop.SUT.NETWORK.CAPABILITY.EIA}              |
      | nas_pdu.attach_request.ue_network_capability.eea                                 | {abotprop.SUT.NETWORK.CAPABILITY.EEA}              |
      | nas_pdu.attach_request.ue_network_capability.uea                                 | {abotprop.SUT.NETWORK.CAPABILITY.UEA}              |
      | nas_pdu.esm_message.protocol_discriminator.esm                                   | {abotprop.SUT.NAS.ESM.PROTO.ESM}                   |
      | nas_pdu.esm_message.eps_bearer_identity.esm                                      | {abotprop.SUT.NAS.ESM.EPS.BEARER.IDN.ESM}          |
      | nas_pdu.esm_message.pti                                                          | 1                                                  |
      | nas_pdu.esm_message.message_type.esm                                             | 0xd0                                               |
      | nas_pdu.esm_message.pdn_connectivity_request.request_type                        | {abotprop.SUT.NAS.ESM.PDN.CON.REQ.REQ.TYPE}        |
      | nas_pdu.esm_message.pdn_connectivity_request.pdn_type                            | {abotprop.SUT.NAS.ESM.PDN.CON.REQ.PDN.TYPE}        |
      | nas_pdu.esm_message.pdn_connectivity_request.pco.configuration_protocol          | {abotprop.SUT.NAS.ESM.PCO.CONFIG.PROTO}            |
      | nas_pdu.esm_message.pdn_connectivity_request.pco.num_protocol_id_or_container_id | {abotprop.SUT.NAS.ESM.PCO.CONFIG.PID.OR.CID}       |
      | nas_pdu.esm_message.pdn_connectivity_request.pco.protocol_contents.0.id          | {abotprop.SUT.NAS.ESM.PCO.PROTO.CONTENTS.ID}       |
      | nas_pdu.esm_message.pdn_connectivity_request.pco.protocol_contents.0.length      | {abotprop.SUT.NAS.ESM.PCO.PROTO.CONTENTS.LEN}      |
      | nas_pdu.esm_message.pdn_connectivity_request.pco.protocol_contents.0.contents    | {abotprop.SUT.NAS.ESM.PCO.PROTO.CONTENTS.CONTENTS} |
      | tai.plmn_identity.mcc                                                            | {abotprop.SUT.MCC}                                 |
      | tai.plmn_identity.mnc                                                            | {abotprop.SUT.MNC}                                 |
      | tai.tac                                                                          | {abotprop.SUT.TAC}                                 |
      | eutran_cgi.plmn_identity.mcc                                                     | {abotprop.SUT.MCC}                                 |
      | eutran_cgi.plmn_identity.mnc                                                     | {abotprop.SUT.MNC}                                 |
      | eutran_cgi.cell_id                                                               | {abotprop.SUT.CGI.CELL.ID}                         |
      | rrc_establishment_cause                                                          | {abotprop.SUT.RRC.ESTABLISHMENT.CAUSE}             |

    Then I receive and validate S1AP message S1_INIT_UE_MSG_NAS_ATTACH_REQ_PDN_CON_REQ on interface S1-MME with the following details on node MME1 from eNodeB1:
      | parameter                                                                        | value                                                           |
      | enb_ue_s1ap_id                                                                   | save(ENB_UE_S1AP_ID)                                            |
      | nas_pdu.protocol_discriminator.emm                                               | {string:eq}({abotprop.SUT.NAS.PROTO.EMM})                       |
      | nas_pdu.security_header_type.plain                                               | {string:eq}({abotprop.SUT.NAS.SECURITY.HEAD.PLAIN})             |
      | nas_pdu.message_type.emm                                                         | {string:eq}({abotprop.SUT.NAS.ATTACH.REQ.MSG.EMM})              |
      | nas_pdu.attach_request.eps_attach_type                                           | {string:eq}({abotprop.SUT.NAS.ATTACH.REQ.EPS.ATTACH.TYPE})      |
      | nas_pdu.attach_request.type_of_security_context                                  | {string:eq}({abotprop.SUT.NAS.TYPE.OF.SEC.CTXT})                |
      | nas_pdu.attach_request.nas_key_set_identifier                                    | save(KEY_SET_ID)                                                |
      #| nas_pdu.attach_request.nas_key_set_identifier                                    | {string:notcontains}(-1)                                        |
      | nas_pdu.attach_request.eps_mobile_identity.imsi                                  | save(IMSI)                                                      |
      | nas_pdu.attach_request.ue_network_capability.eia                                 | {string:eq}({abotprop.SUT.NETWORK.CAPABILITY.EIA})              |
      | nas_pdu.attach_request.ue_network_capability.eea                                 | {string:eq}({abotprop.SUT.NETWORK.CAPABILITY.EEA})              |
      | nas_pdu.attach_request.ue_network_capability.uea                                 | {string:eq}({abotprop.SUT.NETWORK.CAPABILITY.UEA})              |
      | nas_pdu.esm_message.protocol_discriminator.esm                                   | {string:eq}({abotprop.SUT.NAS.ESM.PROTO.ESM})                   |
      | nas_pdu.esm_message.eps_bearer_identity.esm                                      | {string:eq}({abotprop.SUT.NAS.ESM.EPS.BEARER.IDN.ESM})          |
      | nas_pdu.esm_message.pti                                                          | {string:eq}(1)                                                  |
      | nas_pdu.esm_message.message_type.esm                                             | {string:eq}(0xd0)                                               |
      | nas_pdu.esm_message.pdn_connectivity_request.request_type                        | {string:eq}({abotprop.SUT.NAS.ESM.PDN.CON.REQ.REQ.TYPE})        |
      | nas_pdu.esm_message.pdn_connectivity_request.pdn_type                            | {string:eq}({abotprop.SUT.NAS.ESM.PDN.CON.REQ.PDN.TYPE})        |
      | nas_pdu.esm_message.pdn_connectivity_request.pco.configuration_protocol          | {string:eq}({abotprop.SUT.NAS.ESM.PCO.CONFIG.PROTO})            |
      | nas_pdu.esm_message.pdn_connectivity_request.pco.num_protocol_id_or_container_id | {string:eq}({abotprop.SUT.NAS.ESM.PCO.CONFIG.PID.OR.CID})       |
      | nas_pdu.esm_message.pdn_connectivity_request.pco.protocol_contents.0.id          | {string:eq}({abotprop.SUT.NAS.ESM.PCO.PROTO.CONTENTS.ID})       |
      | nas_pdu.esm_message.pdn_connectivity_request.pco.protocol_contents.0.length      | {string:eq}({abotprop.SUT.NAS.ESM.PCO.PROTO.CONTENTS.LEN})      |
      | nas_pdu.esm_message.pdn_connectivity_request.pco.protocol_contents.0.contents    | {string:eq}({abotprop.SUT.NAS.ESM.PCO.PROTO.CONTENTS.CONTENTS}) |
      | tai.plmn_identity.mcc                                                            | {integer:eq}({abotprop.SUT.MCC})                                |
      | tai.plmn_identity.mnc                                                            | {integer:eq}({abotprop.SUT.MNC})                                |
      | tai.tac                                                                          | {integer:eq}({abotprop.SUT.TAC})                                |
      | eutran_cgi.plmn_identity.mcc                                                     | {integer:eq}({abotprop.SUT.MCC})                                |
      | eutran_cgi.plmn_identity.mnc                                                     | {integer:eq}({abotprop.SUT.MNC})                                |
      | eutran_cgi.cell_id                                                               | {string:eq}({abotprop.SUT.CGI.CELL.ID})                         |
      | rrc_establishment_cause                                                          | {string:eq}({abotprop.SUT.RRC.ESTABLISHMENT.CAUSE})             |

    When I send DIAMETER message DIA_AUTHENTICATION_INFORMATION_REQUEST on interface S6A with the following details from node MME1 to HSS1:
      | parameter                                                         | value                                       |
      | Hop-by-Hop Identifier                                             | 124                                         |
      | End-to-End Identifier                                             | 456                                         |
      | Session-Id                                                        | incr({abotprop.SUT.3GPP.S6A.SESSION.ID1},1) |
      | DRMP                                                              | 1                                           |
      | Vendor-Specific-Application-Id.Vendor-Id                          | {abotprop.SUT.3GPP.VENDOR.ID}               |
      | Vendor-Specific-Application-Id.Auth-Application-Id                | {abotprop.SUT.3GPP.S6A.APPID}               |
      | Vendor-Specific-Application-Id.Acct-Application-Id                | 86                                          |
      | Auth-Session-State                                                | 1                                           |
      | Origin-Host                                                       | {abotprop.SUT.S6A.CAPEX.ORIGIN.HOST}        |
      | Origin-Realm                                                      | {abotprop.SUT.S6A.CAPEX.ORIGIN.REALM}       |
      | Destination-Host                                                  | {abotprop.SUT.S6A.CAPEX.DEST.HOST}          |
      | Destination-Realm                                                 | {abotprop.SUT.S6A.CAPEX.DEST.REALM}         |
      | User-Name                                                         | $(IMSI)                                     |
      | OC-Supported-Features.OC-Feature-Vector                           | 88                                          |
      | Supported-Features.Vendor-Id                                      | 22                                          |
      | Supported-Features.Feature-List-ID                                | 25                                          |
      | Supported-Features.Feature-List                                   | 28                                          |
      | Requested-EUTRAN-Authentication-Info.Number-Of-Requested-Vectors  | 1                                           |
      | Requested-EUTRAN-Authentication-Info.Immediate-Response-Preferred | 0                                           |
      | Visited-PLMN-Id                                                   | {abotprop.SUT.VISITED.PLMN.ID}              |
      

    Then I receive and validate DIAMETER message DIA_AUTHENTICATION_INFORMATION_REQUEST on interface S6A with the following details on node HSS1 from MME1:
      | parameter                                                         | value                                              |
      | Hop-by-Hop Identifier                                             | save(HOP_BY_HOP_ID)                                |
      | End-to-End Identifier                                             | save(END_TO_END_ID)                                |
      | Session-Id                                                        | save(DIA_SESS_ID_S6A)                              |
      | DRMP                                                              | {integer:eq}(1)                                    |
      | Vendor-Specific-Application-Id.Vendor-Id                          | {string:eq}({abotprop.SUT.3GPP.VENDOR.ID})         |
      | Vendor-Specific-Application-Id.Auth-Application-Id                | {string:eq}({abotprop.SUT.3GPP.S6A.APPID})         |
      | Vendor-Specific-Application-Id.Acct-Application-Id                | {integer:eq}(86)                                   |
      | Auth-Session-State                                                | {integer:eq}(1)                                    |
      | Origin-Host                                                       | {string:eq}({abotprop.SUT.S6A.CAPEX.ORIGIN.HOST})  |
      | Origin-Realm                                                      | {string:eq}({abotprop.SUT.S6A.CAPEX.ORIGIN.REALM}) |
      | Destination-Host                                                  | {string:eq}({abotprop.SUT.S6A.CAPEX.DEST.HOST})    |
      | Destination-Realm                                                 | {string:eq}({abotprop.SUT.S6A.CAPEX.DEST.REALM})   |
      | User-Name                                                         | save(IMSI)                                         |
      | OC-Supported-Features.OC-Feature-Vector                           | {integer:eq}(88)                                   |
      | Supported-Features.Vendor-Id                                      | {integer:eq}(22)                                   |
      | Supported-Features.Feature-List-ID                                | {integer:eq}(25)                                   |
      | Supported-Features.Feature-List                                   | {integer:eq}(28)                                   |
      | Requested-EUTRAN-Authentication-Info.Number-Of-Requested-Vectors  | {integer:eq}(1)                                    |
      | Requested-EUTRAN-Authentication-Info.Immediate-Response-Preferred | {integer:eq}(0)                                    |
      | Visited-PLMN-Id                                                   | {integer:eq}({abotprop.SUT.VISITED.PLMN.ID})       |

    When I send DIAMETER message DIA_AUTHENTICATION_INFORMATION_ANSWER on interface S6A with the following details from node HSS1 to MME1:
      | parameter                                            | value                                      |
      | Hop-by-Hop Identifier                                | $(HOP_BY_HOP_ID)                           |
      | End-to-End Identifier                                | $(END_TO_END_ID)                           |
      | Session-Id                                           | $(DIA_SESS_ID_S6A)                         |
      | DRMP                                                 | 1                                          |
      | Vendor-Specific-Application-Id.Vendor-Id             | {abotprop.SUT.3GPP.VENDOR.ID}              |
      | Vendor-Specific-Application-Id.Auth-Application-Id   | {abotprop.SUT.3GPP.S6A.APPID}              |
      | Vendor-Specific-Application-Id.Acct-Application-Id   | 86                                         |
      | Result-Code                                          | {abotprop.SUT.3GPP.S6A.DIA_RESULT_CODE}    |
      | Experimental-Result.Vendor-Id                        | 0                                          |
      | Experimental-Result.Experimental-Result-Code         | 255                                        |
      | Error-Diagnostic                                     | 4                                          |
      | Auth-Session-State                                   | 1                                          |
      | Origin-Host                                          | {abotprop.SUT.S6A.CAPEX.ORIGIN.HOST}       |
      | Origin-Realm                                         | {abotprop.SUT.S6A.CAPEX.ORIGIN.REALM}      |
      | OC-Supported-Features.OC-Feature-Vector              | 88                                         |
      | OC-OLR.OC-Sequence-Number                            | 18446744073709551615                       |
      | OC-OLR.OC-Report-Type                                | 1                                          |
      | OC-OLR.OC-Reduction-Percentage                       | 50                                         |
      | OC-OLR.OC-Validity-Duration                          | 4294967295                                 |
      | Supported-Features.Vendor-Id                         | 22                                         |
      | Supported-Features.Feature-List-ID                   | 25                                         |
      | Supported-Features.Feature-List                      | 28                                         |
      | Authentication-Info.E-UTRAN-Vector.Item-Number       | 22                                         |
      | Authentication-Info.E-UTRAN-Vector.RAND              | {abotprop.SUT.MILENAGE.RAND}               |
      | Authentication-Info.E-UTRAN-Vector.XRES              | {abotprop.SUT.MILENAGE.XRES}               |
      | Authentication-Info.E-UTRAN-Vector.AUTN              | {abotprop.SUT.MILENAGE.AUTN}               |
      | Authentication-Info.E-UTRAN-Vector.KASME             | {abotprop.SUT.MILENAGE.KASME}              |
      | Authentication-Info.UTRAN-Vector.Item-Number         | 22                                         |
      | Authentication-Info.UTRAN-Vector.RAND                | {abotprop.SUT.MILENAGE.RAND}               |
      | Authentication-Info.UTRAN-Vector.XRES                | {abotprop.SUT.MILENAGE.XRES}               |
      | Authentication-Info.UTRAN-Vector.AUTN                | {abotprop.SUT.MILENAGE.AUTN}               |
      | Authentication-Info.UTRAN-Vector.Confidentiality-Key | {abotprop.SUT.MILENAGE.CONFIDENTIALIT-KEY} |
      | Authentication-Info.UTRAN-Vector.Integrity-Key       | {abotprop.SUT.MILENAGE.INTEGRITY-KEY}      |

    Then I receive and validate DIAMETER message DIA_AUTHENTICATION_INFORMATION_ANSWER on interface S6A with the following details on node MME1 from HSS1:
      | parameter                                            | value                                                   |
      | Hop-by-Hop Identifier                                | save(HOP_BY_HOP_ID)                                     |
      | End-to-End Identifier                                | save(END_TO_END_ID)                                     |
      | Session-Id                                           | save(DIA_SESS_ID_S6A)                                   |
      | DRMP                                                 | {integer:eq}(1)                                         |
      | Vendor-Specific-Application-Id.Vendor-Id             | {string:eq}({abotprop.SUT.3GPP.VENDOR.ID})              |
      | Vendor-Specific-Application-Id.Auth-Application-Id   | {string:eq}({abotprop.SUT.3GPP.S6A.APPID})              |
      | Vendor-Specific-Application-Id.Acct-Application-Id   | {integer:eq}(86)                                        |
      | Result-Code                                          | {integer:eq}({abotprop.SUT.3GPP.S6A.DIA_RESULT_CODE})   |
      | Experimental-Result.Vendor-Id                        | {integer:eq}(0)                                         |
      | Experimental-Result.Experimental-Result-Code         | {integer:eq}(255)                                       |
      | Error-Diagnostic                                     | {integer:eq}(4)                                         |
      | Auth-Session-State                                   | {integer:eq}(1)                                         |
      | Origin-Host                                          | {string:eq}({abotprop.SUT.S6A.CAPEX.ORIGIN.HOST})       |
      | Origin-Realm                                         | {string:eq}({abotprop.SUT.S6A.CAPEX.ORIGIN.REALM})      |
      | OC-Supported-Features.OC-Feature-Vector              | {integer:eq}(88)                                        |
      | OC-OLR.OC-Sequence-Number                            | {integer:eq}(18446744073709551615)                      |
      | OC-OLR.OC-Report-Type                                | {integer:eq}(1)                                         |
      | OC-OLR.OC-Reduction-Percentage                       | {integer:eq}(50)                                        |
      | OC-OLR.OC-Validity-Duration                          | {integer:eq}(4294967295)                                |
      | Supported-Features.Vendor-Id                         | {integer:eq}(22)                                        |
      | Supported-Features.Feature-List-ID                   | {integer:eq}(25)                                        |
      | Supported-Features.Feature-List                      | {integer:eq}(28)                                        |
      | Authentication-Info.E-UTRAN-Vector.Item-Number       | {integer:eq}(22)                                        |
      | Authentication-Info.E-UTRAN-Vector.RAND              | {string:eq}({abotprop.SUT.MILENAGE.RAND})               |
      | Authentication-Info.E-UTRAN-Vector.XRES              | {string:eq}({abotprop.SUT.MILENAGE.XRES})               |
      | Authentication-Info.E-UTRAN-Vector.AUTN              | {string:eq}({abotprop.SUT.MILENAGE.AUTN})               |
      | Authentication-Info.E-UTRAN-Vector.KASME             | {string:eq}({abotprop.SUT.MILENAGE.KASME})              |
      | Authentication-Info.UTRAN-Vector.Item-Number         | {integer:eq}(22)                                        |
      | Authentication-Info.UTRAN-Vector.RAND                | {string:eq}({abotprop.SUT.MILENAGE.RAND})               |
      | Authentication-Info.UTRAN-Vector.XRES                | {string:eq}({abotprop.SUT.MILENAGE.XRES})               |
      | Authentication-Info.UTRAN-Vector.AUTN                | {string:eq}({abotprop.SUT.MILENAGE.AUTN})               |
      | Authentication-Info.UTRAN-Vector.Confidentiality-Key | {string:eq}({abotprop.SUT.MILENAGE.CONFIDENTIALIT-KEY}) |
      | Authentication-Info.UTRAN-Vector.Integrity-Key       | {string:eq}({abotprop.SUT.MILENAGE.INTEGRITY-KEY})      |

    When I send S1AP message S1_DOWNLINK_NAS_AUTHENTICATION_REQ on interface S1-MME with the following details from node MME1 to eNodeB1:
      | parameter                                               | value                                  |
      | mme_ue_s1ap_id                                          | incr(92274976,1)                       |
      | enb_ue_s1ap_id                                          | $(ENB_UE_S1AP_ID)                      |
      | nas_pdu.protocol_discriminator.emm                      | {abotprop.SUT.NAS.PROTO.EMM}           |
      | nas_pdu.security_header_type.plain                      | {abotprop.SUT.NAS.SECURITY.HEAD.PLAIN} |
      | nas_pdu.message_type.emm                                | {abotprop.SUT.NAS.AUTH.REQ.MSG.EMM}    |
      | nas_pdu.authentication_request.type_of_security_context | {abotprop.SUT.NAS.TYPE.OF.SEC.CTXT}    |
      | nas_pdu.authentication_request.nas_key_set_identifier   | {abotprop.SUT.NAS.DETACH.KEY.SET.ID}   |
      | nas_pdu.authentication_request.RAND                     | {abotprop.SUT.MILENAGE.RAND}           |
      | nas_pdu.authentication_request.AUTN                     | {abotprop.SUT.MILENAGE.AUTN}           |
      | nas_pdu.authentication_request.AMF                      | {abotprop.SUT.MILENAGE.AMF}            |
      | nas_pdu.authentication_request.K                        | {abotprop.SUT.MILENAGE.K}              |
      | nas_pdu.authentication_request.OP                       | {abotprop.SUT.MILENAGE.OP}             |
      | nas_pdu.authentication_request.selected_plmn            | {abotprop.SUT.SELECTED.PLMN}           |

    Then I receive and validate S1AP message S1_DOWNLINK_NAS_AUTHENTICATION_REQ on interface S1-MME with the following details on node eNodeB1 from MME1:
      | parameter                                               | value                                               |
      | mme_ue_s1ap_id                                          | save(MME_UE_S1AP_ID)                                |
      | enb_ue_s1ap_id                                          | save(ENB_UE_S1AP_ID)                                |
      | nas_pdu.protocol_discriminator.emm                      | {string:eq}({abotprop.SUT.NAS.PROTO.EMM})           |
      | nas_pdu.security_header_type.plain                      | {string:eq}({abotprop.SUT.NAS.SECURITY.HEAD.PLAIN}) |
      | nas_pdu.message_type.emm                                | {string:eq}({abotprop.SUT.NAS.AUTH.REQ.MSG.EMM})    |
      | nas_pdu.authentication_request.type_of_security_context | {string:eq}({abotprop.SUT.NAS.TYPE.OF.SEC.CTXT})    |
      | nas_pdu.authentication_request.nas_key_set_identifier   | save(KEY_SET_ID)                                    |
      #| nas_pdu.authentication_request.nas_key_set_identifier   | {string:notcontains}(-1)                            |
      | nas_pdu.authentication_request.AMF                      | {abotprop.SUT.MILENAGE.AMF}                         |
      | nas_pdu.authentication_request.K                        | {abotprop.SUT.MILENAGE.K}                           |
      | nas_pdu.authentication_request.OP                       | {abotprop.SUT.MILENAGE.OP}                          |
      | nas_pdu.authentication_request.selected_plmn            | {abotprop.SUT.SELECTED.PLMN}                        |
      | nas_pdu.authentication_request.RAND                     | save(RAND)                                          |
      | nas_pdu.authentication_request.AUTN                     | save(AUTN)                                          |
      | nas_pdu.authentication_request.authentication_status    | {string:eq}(SUCCESS)                                |
      | nas_pdu.authentication_request.RES                      | save(NAS_PDU_RES)                                   |

    When I send S1AP message S1_UPLINK_NAS_AUTHENTICATION_RES on interface S1-MME with the following details from node eNodeB1 to MME1:
      | parameter                           | value                                  |
      | mme_ue_s1ap_id                      | $(MME_UE_S1AP_ID)                      |
      | enb_ue_s1ap_id                      | $(ENB_UE_S1AP_ID)                      |
      | nas_pdu.protocol_discriminator.emm  | {abotprop.SUT.NAS.PROTO.EMM}           |
      | nas_pdu.security_header_type.plain  | {abotprop.SUT.NAS.SECURITY.HEAD.PLAIN} |
      | nas_pdu.message_type.emm            | {abotprop.SUT.NAS.AUTH.RES.MSG.EMM}    |
      | nas_pdu.authentication_response.RES | $(NAS_PDU_RES)                         |
      | eutran_cgi.plmn_identity.mcc        | {abotprop.SUT.MCC}                     |
      | eutran_cgi.plmn_identity.mnc        | {abotprop.SUT.MNC}                     |
      | eutran_cgi.cell_id                  | {abotprop.SUT.CGI.CELL.ID}             |
      | tai.plmn_identity.mcc               | {abotprop.SUT.MCC}                     |
      | tai.plmn_identity.mnc               | {abotprop.SUT.MNC}                     |
      | tai.tac                             | {abotprop.SUT.TAC}                     |

    Then I receive and validate S1AP message S1_UPLINK_NAS_AUTHENTICATION_RES on interface S1-MME with the following details on node MME1 from eNodeB1:
      | parameter                           | value                                               |
      | mme_ue_s1ap_id                      | save(MME_UE_S1AP_ID)                                |
      | enb_ue_s1ap_id                      | $(ENB_UE_S1AP_ID)                                   |
      | nas_pdu.protocol_discriminator.emm  | {string:eq}({abotprop.SUT.NAS.PROTO.EMM})           |
      | nas_pdu.security_header_type.plain  | {string:eq}({abotprop.SUT.NAS.SECURITY.HEAD.PLAIN}) |
      | nas_pdu.message_type.emm            | {string:eq}({abotprop.SUT.NAS.AUTH.RES.MSG.EMM})    |
      | nas_pdu.authentication_response.RES | {string:eq}($(NAS_PDU_RES))                         |
      | eutran_cgi.plmn_identity.mcc        | {integer:eq}({abotprop.SUT.MCC})                    |
      | eutran_cgi.plmn_identity.mnc        | {integer:eq}({abotprop.SUT.MNC})                    |
      | eutran_cgi.cell_id                  | {string:eq}({abotprop.SUT.CGI.CELL.ID})             |
      | tai.plmn_identity.mcc               | {integer:eq}({abotprop.SUT.MCC})                    |
      | tai.plmn_identity.mnc               | {integer:eq}({abotprop.SUT.MNC})                    |
      | tai.tac                             | {integer:eq}({abotprop.SUT.TAC})                    |

    When I send S1AP message S1_DOWNLINK_NAS_SECURITY_MODE_CMD on interface S1-MME with the following details from node MME1 to eNodeB1:
      | parameter                                                 | value                                  |
      | mme_ue_s1ap_id                                            | $(MME_UE_S1AP_ID)                      |
      | enb_ue_s1ap_id                                            | $(ENB_UE_S1AP_ID)                      |
      | nas_pdu.protocol_discriminator.emm                        | 0x07                                   |
      | nas_pdu.security_header_protocol_discriminator            | {abotprop.SUT.SECURITY_HEADER_PD}      |
      | nas_pdu.security_header_type.plain                        | {abotprop.SUT.NAS.SECURITY.HEAD.PLAIN} |
      | nas_pdu.message_type.emm                                  | {abotprop.SUT.NAS.SEC.MOD.CMD.MSG.EMM} |
      | nas_pdu.security_header_type.protected                    | 3                                      |
      | nas_pdu.message_authentication_code                       | {abotprop.SUT.NAS.AUTH.CODE}           |
      | nas_pdu.sequence_number                                   | {abotprop.SUT.NAS.MME.SEQ.NO.OFFSET}   |
      | nas_pdu.security_mode_command.nas_security_algorithms.eea | {abotprop.SUT.SECURITY.ALGO.EEA}       |
      | nas_pdu.security_mode_command.nas_security_algorithms.eia | {abotprop.SUT.SECURITY.ALGO.EIA}       |
      | nas_pdu.security_mode_command.ue_security_capability.eia  | {abotprop.SUT.SECURITY.CAPABILITY.EIA} |
      | nas_pdu.security_mode_command.ue_security_capability.eea  | {abotprop.SUT.SECURITY.CAPABILITY.EEA} |
      | nas_pdu.security_mode_command.nas_key_set_identifier      | 0                                      |
      | nas_pdu.security_mode_command.type_of_security_context    | {abotprop.SUT.NAS.TYPE.OF.SEC.CTXT}    |

    Then I receive and validate S1AP message S1_DOWNLINK_NAS_SECURITY_MODE_CMD on interface S1-MME with the following details on node eNodeB1 from MME1:
      | parameter                                                 | value                                               |
      | mme_ue_s1ap_id                                            | $(MME_UE_S1AP_ID)                                   |
      | enb_ue_s1ap_id                                            | $(ENB_UE_S1AP_ID)                                   |
      | nas_pdu.protocol_discriminator.emm                        | {string:eq}({abotprop.SUT.NAS.PROTO.EMM})           |
      | nas_pdu.security_header_protocol_discriminator            | {string:eq}({abotprop.SUT.SECURITY_HEADER_PD})      |
      | nas_pdu.security_header_type.plain                        | {string:eq}({abotprop.SUT.NAS.SECURITY.HEAD.PLAIN}) |
      | nas_pdu.message_type.emm                                  | {string:eq}({abotprop.SUT.NAS.SEC.MOD.CMD.MSG.EMM}) |
      | nas_pdu.security_header_type.protected                    | {string:eq}(3)                                      |
      | nas_pdu.message_authentication_code                       | save(NAS_AUTH_CODE)                                 |
      | nas_pdu.sequence_number                                   | save(NAS_MME_SEQ_NO)                                |
      | nas_pdu.security_mode_command.nas_security_algorithms.eea | {integer:eq}({abotprop.SUT.SECURITY.ALGO.EEA})      |
      | nas_pdu.security_mode_command.nas_security_algorithms.eia | {integer:eq}({abotprop.SUT.SECURITY.ALGO.EIA})      |
      | nas_pdu.security_mode_command.ue_security_capability.eia  | {string:eq}({abotprop.SUT.SECURITY.CAPABILITY.EIA}) |
      | nas_pdu.security_mode_command.ue_security_capability.eea  | {string:eq}({abotprop.SUT.SECURITY.CAPABILITY.EEA}) |
      | nas_pdu.security_mode_command.nas_key_set_identifier      | save(KEY_SET_ID)                                    |
      #| nas_pdu.security_mode_command.nas_key_set_identifier      | {string:notcontains}(-1)                            |
      | nas_pdu.security_mode_command.type_of_security_context    | {string:eq}({abotprop.SUT.NAS.TYPE.OF.SEC.CTXT})    |

    When I send S1AP message S1_UPLINK_NAS_SECURITY_MODE_COMPLETE on interface S1-MME with the following details from node eNodeB1 to MME1:
      | parameter                                      | value                                  |
      | mme_ue_s1ap_id                                 | $(MME_UE_S1AP_ID)                      |
      | enb_ue_s1ap_id                                 | $(ENB_UE_S1AP_ID)                      |
      | nas_pdu.protocol_discriminator.emm             | {abotprop.SUT.NAS.PROTO.EMM}           |
      | nas_pdu.security_header_protocol_discriminator | {abotprop.SUT.SECURITY_HEADER_PD}      |
      | nas_pdu.security_header_type.plain             | {abotprop.SUT.NAS.SECURITY.HEAD.PLAIN} |
      | nas_pdu.message_type.emm                       | {abotprop.SUT.NAS.SEC.MOD.COM.MSG.EMM} |
      | nas_pdu.security_header_type.protected         | 4                                      |
      | nas_pdu.sequence_number                        | {abotprop.SUT.NAS.UE.SEQ.NO.OFFSET}    |
      | eutran_cgi.plmn_identity.mcc                   | {abotprop.SUT.MCC}                     |
      | eutran_cgi.plmn_identity.mnc                   | {abotprop.SUT.MNC}                     |
      | eutran_cgi.cell_id                             | {abotprop.SUT.CGI.CELL.ID}             |
      | tai.plmn_identity.mcc                          | {abotprop.SUT.MCC}                     |
      | tai.plmn_identity.mnc                          | {abotprop.SUT.MNC}                     |
      | tai.tac                                        | {abotprop.SUT.TAC}                     |

    Then I receive and validate S1AP message S1_UPLINK_NAS_SECURITY_MODE_COMPLETE on interface S1-MME with the following details on node MME1 from eNodeB1:
      | parameter                                      | value                                               |
      | mme_ue_s1ap_id                                 | $(MME_UE_S1AP_ID)                                   |
      | enb_ue_s1ap_id                                 | $(ENB_UE_S1AP_ID)                                   |
      | nas_pdu.protocol_discriminator.emm             | {string:eq}({abotprop.SUT.NAS.PROTO.EMM})           |
      | nas_pdu.security_header_protocol_discriminator | {string:eq}({abotprop.SUT.SECURITY_HEADER_PD)}      |
      | nas_pdu.security_header_type.plain             | {string:eq}({abotprop.SUT.NAS.SECURITY.HEAD.PLAIN}) |
      | nas_pdu.message_type.emm                       | {string:eq}({abotprop.SUT.NAS.SEC.MOD.COM.MSG.EMM}) |
      | nas_pdu.security_header_type.protected         | {string:eq}(4)                                      |
      | nas_pdu.sequence_number                        | save(NAS_UE_SEQ_NO)                                 |
      | eutran_cgi.plmn_identity.mcc                   | {integer:eq}({abotprop.SUT.MCC})                    |
      | eutran_cgi.plmn_identity.mnc                   | {integer:eq}({abotprop.SUT.MNC})                    |
      | eutran_cgi.cell_id                             | {string:eq}({abotprop.SUT.CGI.CELL.ID})             |
      | tai.plmn_identity.mcc                          | {integer:eq}({abotprop.SUT.MCC})                    |
      | tai.plmn_identity.mnc                          | {integer:eq}({abotprop.SUT.MNC})                    |
      | tai.tac                                        | {string:eq}({abotprop.SUT.TAC})                     |

    When I send S1AP message S1_DOWNLINK_NAS_IDENTITY_REQ on interface S1-MME with the following details from node MME1 to eNodeB1:
      | parameter                               | value                                         |
      | mme_ue_s1ap_id                          | $(MME_UE_S1AP_ID)                             |
      | enb_ue_s1ap_id                          | $(ENB_UE_S1AP_ID)                             |
      | nas_pdu.protocol_discriminator.emm      | {abotprop.SUT.NAS.PROTO.EMM}                  |
      | nas_pdu.security_header_type.plain      | {abotprop.SUT.NAS.SECURITY.HEAD.PLAIN}        |
      | nas_pdu.message_type.emm                | {abotprop.SUT.NAS.IDENTITY.REQ.MSG.EMM}       |
      | nas_pdu.identity_request.identity_type2 | {abotprop.SUT.NAS.IDENTITY.REQ.IDENTITY.TYPE} |

    Then I receive and validate S1AP message S1_DOWNLINK_NAS_IDENTITY_REQ on interface S1-MME with the following details on node eNodeB1 from MME1:
      | parameter                               | value                                                |
      | mme_ue_s1ap_id                          | {string:eq}($(MME_UE_S1AP_ID))                       |
      | enb_ue_s1ap_id                          | {string:eq}($(ENB_UE_S1AP_ID))                       |
      | nas_pdu.protocol_discriminator.emm      | {string:eq}({abotprop.SUT.NAS.PROTO.EMM})            |
      | nas_pdu.security_header_type.plain      | {string:eq}({abotprop.SUT.NAS.SECURITY.HEAD.PLAIN})  |
      | nas_pdu.message_type.emm                | {string:eq}({abotprop.SUT.NAS.IDENTITY.REQ.MSG.EMM}) |
      | nas_pdu.identity_request.identity_type2 | save(IDN_TYP2)                                       |

    When I send S1AP message S1_UPLINK_NAS_IDENTITY_RES on interface S1-MME with the following details from node eNodeB1 to MME1:
      | parameter                                      | value                                   |
      | mme_ue_s1ap_id                                 | $(MME_UE_S1AP_ID)                       |
      | enb_ue_s1ap_id                                 | $(ENB_UE_S1AP_ID)                       |
      | nas_pdu.protocol_discriminator.emm             | {abotprop.SUT.NAS.PROTO.EMM}            |
      | nas_pdu.security_header_protocol_discriminator | {abotprop.SUT.SECURITY_HEADER_PD}       |
      | nas_pdu.security_header_type.plain             | {abotprop.SUT.NAS.SECURITY.HEAD.PLAIN}  |
      | nas_pdu.message_type.emm                       | {abotprop.SUT.NAS.IDENTITY.RES.MSG.EMM} |
      | nas_pdu.identity_response.mobile_identity.imsi | {abotprop.SUT.IMSI.START}               |
      | eutran_cgi.plmn_identity.mcc                   | {abotprop.SUT.MCC}                      |
      | eutran_cgi.plmn_identity.mnc                   | {abotprop.SUT.MNC}                      |
      | eutran_cgi.cell_id                             | {abotprop.SUT.CGI.CELL.ID}              |
      | tai.plmn_identity.mcc                          | {abotprop.SUT.MCC}                      |
      | tai.plmn_identity.mnc                          | {abotprop.SUT.MNC}                      |
      | tai.tac                                        | {abotprop.SUT.TAC}                      |

    Then I receive and validate S1AP message S1_UPLINK_NAS_IDENTITY_RES on interface S1-MME with the following details on node MME1 from eNodeB1:
      | parameter                                      | value                                                |
      | mme_ue_s1ap_id                                 | {string:eq}($(MME_UE_S1AP_ID))                       |
      | enb_ue_s1ap_id                                 | {string:eq}($(ENB_UE_S1AP_ID))                       |
      | nas_pdu.protocol_discriminator.emm             | {string:eq}({abotprop.SUT.NAS.PROTO.EMM})            |
      | nas_pdu.security_header_protocol_discriminator | {string:eq}({abotprop.SUT.SECURITY_HEADER_PD})       |
      | nas_pdu.security_header_type.plain             | {string:eq}({abotprop.SUT.NAS.SECURITY.HEAD.PLAIN})  |
      | nas_pdu.message_type.emm                       | {string:eq}({abotprop.SUT.NAS.IDENTITY.RES.MSG.EMM}) |
      | nas_pdu.identity_response.mobile_identity.imsi | save(IMSI)                                           |
      | eutran_cgi.plmn_identity.mcc                   | {string:eq}({abotprop.SUT.MCC})                      |
      | eutran_cgi.plmn_identity.mnc                   | {string:eq}({abotprop.SUT.MNC})                      |
      | eutran_cgi.cell_id                             | {string:eq}({abotprop.SUT.CGI.CELL.ID})              |
      | tai.plmn_identity.mcc                          | {string:eq}({abotprop.SUT.MCC})                      |
      | tai.plmn_identity.mnc                          | {string:eq}({abotprop.SUT.MNC})                      |
      | tai.tac                                        | {string:eq}({abotprop.SUT.TAC})                      |

    When I send DIAMETER message DIA_UPDATE_LOCATION_REQUEST on interface S6A with the following details from node MME1 to HSS1:
      | parameter             | value                                 |
      | Hop-by-Hop Identifier | 125                                   |
      | End-to-End Identifier | 456                                   |
      | Session-Id            | $(DIA_SESS_ID_S6A)                    |
      | Auth-Session-State    | 1                                     |
      | Origin-Host           | {abotprop.SUT.S6A.CAPEX.ORIGIN.HOST}  |
      | Origin-Realm          | {abotprop.SUT.S6A.CAPEX.ORIGIN.REALM} |
      | Destination-Host      | {abotprop.SUT.S6A.CAPEX.DEST.HOST}    |
      | Destination-Realm     | {abotprop.SUT.S6A.CAPEX.DEST.REALM}   |
      | User-Name             | $(IMSI)                               |
      | Visited-PLMN-Id       | {abotprop.SUT.VISITED.PLMN.ID}        |
      | RAT-Type              | 1004                                  |
      | ULR-Flags             | 34                                    |

    Then I receive and validate DIAMETER message DIA_UPDATE_LOCATION_REQUEST on interface S6A with the following details on node HSS1 from MME1:
      | parameter             | value                                              |
      | Hop-by-Hop Identifier | save(HOP_BY_HOP_ID)                                |
      | End-to-End Identifier | save(END_TO_END_ID)                                |
      | Session-Id            | {string:eq}($(DIA_SESS_ID_S6A))                    |
      | Auth-Session-State    | {integer:eq}(1)                                    |
      | Origin-Host           | {string:eq}({abotprop.SUT.S6A.CAPEX.ORIGIN.HOST})  |
      | Origin-Realm          | {string:eq}({abotprop.SUT.S6A.CAPEX.ORIGIN.REALM}) |
      | Destination-Host      | {string:eq}({abotprop.SUT.S6A.CAPEX.DEST.HOST})    |
      | Destination-Realm     | {string:eq}({abotprop.SUT.S6A.CAPEX.DEST.REALM})   |
      | User-Name             | save(IMSI)                                         |
      | Visited-PLMN-Id       | {integer:eq}({abotprop.SUT.VISITED.PLMN.ID})       |
      | RAT-Type              | {integer:eq}(1004)                                 |
      | ULR-Flags             | {integer:eq}(34)                                   |

    When I send DIAMETER message DIA_UPDATE_LOCATION_ANSWER on interface S6A with the following details from node HSS1 to MME1:
      | parameter                                                                                                                                        | value                                             |
      | Hop-by-Hop Identifier                                                                                                                            | $(HOP_BY_HOP_ID)                                  |
      | End-to-End Identifier                                                                                                                            | $(END_TO_END_ID)                                  |
      | Session-Id                                                                                                                                       | $(DIA_SESS_ID_S6A)                                |
      | ULA-Flags                                                                                                                                        | 1                                                 |
      | Subscription-Data.MSISDN                                                                                                                         | {abotprop.SUT.MSISDN.START}                       |
      | Subscription-Data.Access-Restriction-Data                                                                                                        | 47                                                |
      | Subscription-Data.Subscriber-Status                                                                                                              | 0                                                 |
      | Subscription-Data.Network-Access-Mode                                                                                                            | 2                                                 |
      | Subscription-Data.AMBR.Max-Requested-Bandwidth-UL                                                                                                | {abotprop.SUT.UE.AMBR.UL}                         |
      | Subscription-Data.AMBR.Max-Requested-Bandwidth-DL                                                                                                | {abotprop.SUT.UE.AMBR.DL}                         |
      | Subscription-Data.APN-Configuration-Profile.Context-Identifier                                                                                   | 0                                                 |
      | Subscription-Data.APN-Configuration-Profile.All-APN-Configurations-Included-Indicator                                                            | 0                                                 |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.Context-Identifier                                                                 | 0                                                 |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.PDN-Type                                                                           | 1                                                 |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.Service-Selection                                                                  | {abotprop.SUT.PDN.CONNECTIVITY.APN}               |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.EPS-Subscribed-QoS-Profile.QoS-Class-Identifier                                    | {abotprop.SUT.DEF.ERAB.QCI}                       |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.EPS-Subscribed-QoS-Profile.Allocation-Retention-Priority.Priority-Level            | {abotprop.SUT.DEF.ERAB.ARP.PRIORITY.LEVEL}        |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.EPS-Subscribed-QoS-Profile.Allocation-Retention-Priority.Pre-emption-Capability    | {abotprop.SUT.DEF.ERAB.ARP.PREEMPT.CAPABILITY}    |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.EPS-Subscribed-QoS-Profile.Allocation-Retention-Priority.Pre-emption-Vulnerability | {abotprop.SUT.DEF.ERAB.ARP.PREEMPT.VULNERABILITY} |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.AMBR.Max-Requested-Bandwidth-UL                                                    | {abotprop.SUT.UE.AMBR.UL}                         |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.AMBR.Max-Requested-Bandwidth-DL                                                    | {abotprop.SUT.UE.AMBR.DL}                         |
      | Subscription-Data.Subscribed-Periodic-RAU-TAU-Timer                                                                                              | 120                                               |
      | Auth-Session-State                                                                                                                               | 1                                                 |
      | Origin-Host                                                                                                                                      | {abotprop.SUT.S6A.CAPEX.ORIGIN.HOST}              |
      | Origin-Realm                                                                                                                                     | {abotprop.SUT.S6A.CAPEX.ORIGIN.REALM}             |
      | Result-Code                                                                                                                                      | {abotprop.SUT.3GPP.S6A.DIA_RESULT_CODE}           |

    Then I receive and validate DIAMETER message DIA_UPDATE_LOCATION_ANSWER on interface S6A with the following details on node MME1 from HSS1:
      | parameter                                                                                                                                        | value                                                           |
      | Hop-by-Hop Identifier                                                                                                                            | save(HOP_BY_HOP_ID)                                             |
      | End-to-End Identifier                                                                                                                            | save(END_TO_END_ID)                                             |
      | Session-Id                                                                                                                                       | {string:eq}($(DIA_SESS_ID_S6A))                                 |
      | ULA-Flags                                                                                                                                        | {integer:eq}(1)                                                 |
      | Subscription-Data.MSISDN                                                                                                                         | {string:eq}({abotprop.SUT.MSISDN.START})                        |
      | Subscription-Data.Access-Restriction-Data                                                                                                        | {integer:eq}(47)                                                |
      | Subscription-Data.Subscriber-Status                                                                                                              | {integer:eq}(0)                                                 |
      | Subscription-Data.Network-Access-Mode                                                                                                            | {integer:eq}(2)                                                 |
      | Subscription-Data.AMBR.Max-Requested-Bandwidth-UL                                                                                                | {integer:eq}({abotprop.SUT.UE.AMBR.UL})                         |
      | Subscription-Data.AMBR.Max-Requested-Bandwidth-DL                                                                                                | {integer:eq}({abotprop.SUT.UE.AMBR.DL})                         |
      | Subscription-Data.APN-Configuration-Profile.Context-Identifier                                                                                   | {integer:eq}(0)                                                 |
      | Subscription-Data.APN-Configuration-Profile.All-APN-Configurations-Included-Indicator                                                            | {integer:eq}(0)                                                 |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.Context-Identifier                                                                 | {integer:eq}(0)                                                 |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.PDN-Type                                                                           | {integer:eq}(1)                                                 |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.Service-Selection                                                                  | {string:eq}({abotprop.SUT.PDN.CONNECTIVITY.APN})                |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.EPS-Subscribed-QoS-Profile.QoS-Class-Identifier                                    | {integer:eq}({abotprop.SUT.DEF.ERAB.QCI})                       |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.EPS-Subscribed-QoS-Profile.Allocation-Retention-Priority.Priority-Level            | {integer:eq}({abotprop.SUT.DEF.ERAB.ARP.PRIORITY.LEVEL})        |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.EPS-Subscribed-QoS-Profile.Allocation-Retention-Priority.Pre-emption-Capability    | {integer:eq}({abotprop.SUT.DEF.ERAB.ARP.PREEMPT.CAPABILITY})    |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.EPS-Subscribed-QoS-Profile.Allocation-Retention-Priority.Pre-emption-Vulnerability | {integer:eq}({abotprop.SUT.DEF.ERAB.ARP.PREEMPT.VULNERABILITY}) |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.AMBR.Max-Requested-Bandwidth-UL                                                    | {integer:eq}({abotprop.SUT.UE.AMBR.UL})                         |
      | Subscription-Data.APN-Configuration-Profile.APN-Configuration.AMBR.Max-Requested-Bandwidth-DL                                                    | {integer:eq}({abotprop.SUT.UE.AMBR.DL})                         |
      | Subscription-Data.Subscribed-Periodic-RAU-TAU-Timer                                                                                              | {integer:eq}(120)                                               |
      | Auth-Session-State                                                                                                                               | {integer:eq}(1)                                                 |
      | Origin-Host                                                                                                                                      | {abotprop.SUT.S6A.CAPEX.ORIGIN.HOST}                            |
      | Origin-Realm                                                                                                                                     | {abotprop.SUT.S6A.CAPEX.ORIGIN.REALM}                           |
      | Result-Code                                                                                                                                      | {integer:eq}({abotprop.SUT.3GPP.S6A.DIA_RESULT_CODE})           |

    When I send GTPV2C message GTPV2C_CREATE_SESSION_REQUEST on interface S11 with the following details from node MME1 to SGW1:
      | parameter                                                     | value                                      |
      | header.message_type                                           | 32                                         |
      | header.teid                                                   | 0                                          |
      | header.seq_number                                             | 100                                        |
      | recovery                                                      | 0                                          |
      | imsi                                                          | $(IMSI)                                    |
      | msisdn                                                        | incr(22331010101010,1)                     |
      | meid                                                          | incr(123456789012345,1)                    |
      | serving_network.mcc                                           | {abotprop.SUT.MCC}                         |
      | serving_network.mnc                                           | {abotprop.SUT.MNC}                         |
      | rat_type                                                      | 6                                          |
      | indication                                                    | 0x801801                                   |
      | sender_fteid_cntrl_plane.fq_teid.interface_type               | 10                                         |
      | sender_fteid_cntrl_plane.fq_teid.ipv4_flag                    | 1                                          |
      | sender_fteid_cntrl_plane.fq_teid.ipv6_flag                    | 0                                          |
      | sender_fteid_cntrl_plane.fq_teid.teid                         | incr(1,1)                                  |
      | sender_fteid_cntrl_plane.fq_teid.ipv4_add                     | {abotprop.SUT.IPV4_ADDRESS}                |
      | apn                                                           | {abotprop.SUT.3GPP.APN}                    |
      | selection_mode                                                | 2                                          |
      | pdn_type                                                      | {abotprop.SUT.3GPP.PDN_TYPE}               |
      | pdn_address_allocation.pdn_type                               | {abotprop.SUT.3GPP.PDN_TYPE}               |
      | pdn_address_allocation.pdn_address_and_prefix                 | {abotprop.SUT.PDN_ADDRESS}                 |
      | maxm_apn_restriction.apn_restriction_value                    | 2                                          |
      | ambr.apn_ambr_uplink                                          | {abotprop.SUT.MAX_BIT_RATE_UL}             |
      | ambr.apn_ambr_downlink                                        | {abotprop.SUT.MAX_BIT_RATE_DL}             |
      | linked.eps_bearer_id                                          | {abotprop.SUT.3GPP.LINKED.EPS_BEARER_ID1}  |
      | charging_char                                                 | {abotprop.SUT.3GPP.GTPV2C.CHARGING_CHAR}   |
      | protocol_config_options                                       | 0x8080211001000010810600000000830600000000 |
      | ue_timezone.time_zone                                         | 2                                          |
      | ue_timezone.daylight_saving_time                              | 4                                          |
      | lapi                                                          | 0                                          |
      | bearer_contexts_to_create.0.eps_bearer_id                     | {abotprop.SUT.3GPP.EPS_BEARER_ID}          |
      | bearer_contexts_to_create.0.bearer_qos.pvi                    | 0                                          |
      | bearer_contexts_to_create.0.bearer_qos.pl                     | 15                                         |
      | bearer_contexts_to_create.0.bearer_qos.pci                    | 1                                          |
      | bearer_contexts_to_create.0.bearer_qos.qci                    | {abotprop.SUT.3GPP.BEARER_QCI}             |
      | bearer_contexts_to_create.0.bearer_qos.max_bit_rate_ul        | {abotprop.SUT.MAX_BIT_RATE_UL}             |
      | bearer_contexts_to_create.0.bearer_qos.max_bit_rate_dl        | {abotprop.SUT.MAX_BIT_RATE_DL}             |
      | bearer_contexts_to_create.0.bearer_qos.guaranteed_bit_rate_ul | {abotprop.SUT.GUARANTEED_BIT_RATE_UL}      |
      | bearer_contexts_to_create.0.bearer_qos.guaranteed_bit_rate_dl | {abotprop.SUT.GUARANTEED_BIT_RATE_DL}      |
      | bearer_contexts_to_create.0.s1u_enodeb.fq_teid.interface_type | 0                                          |
      | bearer_contexts_to_create.0.s1u_enodeb.fq_teid.ipv4_flag      | 1                                          |
      | bearer_contexts_to_create.0.s1u_enodeb.fq_teid.ipv6_flag      | 0                                          |
      | bearer_contexts_to_create.0.s1u_enodeb.fq_teid.teid           | incr(1,8)                                  |
      | bearer_contexts_to_create.0.s1u_enodeb.fq_teid.ipv4_add       | {abotprop.SUT.IPV4_ADDRESS}                |
      | bearer_contexts_to_create.0.s11u_mme.fq_teid.interface_type   | 38                                         |
      | bearer_contexts_to_create.0.s11u_mme.fq_teid.ipv4_flag        | 1                                          |
      | bearer_contexts_to_create.0.s11u_mme.fq_teid.ipv6_flag        | 0                                          |
      | bearer_contexts_to_create.0.s11u_mme.fq_teid.teid             | incr(1,8)                                  |
      | bearer_contexts_to_create.0.s11u_mme.fq_teid.ipv4_add         | {abotprop.SUT.IPV4_ADDRESS}                |
      | user_location_info.uli_flags                                  | 10                                         |
      | user_location_info.ecgi.plmn_identity.mcc                     | {abotprop.SUT.MCC}                         |
      | user_location_info.ecgi.plmn_identity.mnc                     | {abotprop.SUT.MNC}                         |
      | user_location_info.ecgi.cell_id                               | {abotprop.SUT.ECGI.CELL.ID1}               |
     

    Then I receive and validate GTPV2C message GTPV2C_CREATE_SESSION_REQUEST on interface S11 with the following details on node SGW1 from MME1:
      | parameter                                                     | value                                                   |
      | header.message_type                                           | {string:eq}(32)                                         |
      | header.teid                                                   | {string:eq}(0)                                          |
      | header.seq_number                                             | {string:eq}(100)                                        |
      | recovery                                                      | {string:eq}(0)                                          |
      | imsi                                                          | save(IMSI)                                              |
      | msisdn                                                        | save(MSISDN)                                            |
      | meid                                                          | save(MEID)                                              |
      | serving_network.mcc                                           | {integer:eq}({abotprop.SUT.MCC})                        |
      | serving_network.mnc                                           | {integer:eq}({abotprop.SUT.MNC})                        |
      | rat_type                                                      | {string:eq}(6)                                          |
      | indication                                                    | {string:eq}(0x801801)                                   |
      | sender_fteid_cntrl_plane.fq_teid.interface_type               | {string:eq}(10)                                         |
      | sender_fteid_cntrl_plane.fq_teid.ipv4_flag                    | {string:eq}(1)                                          |
      | sender_fteid_cntrl_plane.fq_teid.ipv6_flag                    | {string:eq}(0)                                          |
      | sender_fteid_cntrl_plane.fq_teid.teid                         | save(GTPV2C_HDR_DL_TEID_MME_S11)                        |
      | sender_fteid_cntrl_plane.fq_teid.ipv4_add                     | {string:eq}({abotprop.SUT.IPV4_ADDRESS})                |
      | apn                                                           | {string:eq}({abotprop.SUT.3GPP.APN})                    |
      | selection_mode                                                | {string:eq}(2)                                          |
      | pdn_type                                                      | {string:eq}({abotprop.SUT.3GPP.PDN_TYPE})               |
      | pdn_address_allocation.pdn_type                               | {string:eq}({abotprop.SUT.3GPP.PDN_TYPE})               |
      | pdn_address_allocation.pdn_address_and_prefix                 | {string:eq}({abotprop.SUT.PDN_ADDRESS})                 |
      | maxm_apn_restriction.apn_restriction_value                    | {string:eq}(2)                                          |
      | ambr.apn_ambr_uplink                                          | {string:eq}({abotprop.SUT.MAX_BIT_RATE_UL})             |
      | ambr.apn_ambr_downlink                                        | {string:eq}({abotprop.SUT.MAX_BIT_RATE_DL})             |
      | linked.eps_bearer_id                                          | {string:eq}({abotprop.SUT.3GPP.LINKED.EPS_BEARER_ID1})  |
      | charging_char                                                 | {string:eq}({abotprop.SUT.3GPP.GTPV2C.CHARGING_CHAR})   |
      | protocol_config_options                                       | {string:eq}(0x8080211001000010810600000000830600000000) |
      | ue_timezone.time_zone                                         | {string:eq}(2)                                          |
      | ue_timezone.daylight_saving_time                              | {string:eq}(4)                                          |
      | lapi                                                          | {string:eq}(0)                                          |
      | bearer_contexts_to_create.0.eps_bearer_id                     | {string:eq}({abotprop.SUT.3GPP.EPS_BEARER_ID})          |
      | bearer_contexts_to_create.0.bearer_qos.pvi                    | {string:eq}(0)                                          |
      | bearer_contexts_to_create.0.bearer_qos.pl                     | {string:eq}(15)                                         |
      | bearer_contexts_to_create.0.bearer_qos.pci                    | {string:eq}(1)                                          |
      | bearer_contexts_to_create.0.bearer_qos.qci                    | save(QCI)                                               |
      | bearer_contexts_to_create.0.bearer_qos.max_bit_rate_ul        | {string:eq}({abotprop.SUT.MAX_BIT_RATE_UL})             |
      | bearer_contexts_to_create.0.bearer_qos.max_bit_rate_dl        | {string:eq}({abotprop.SUT.MAX_BIT_RATE_DL})             |
      | bearer_contexts_to_create.0.bearer_qos.guaranteed_bit_rate_ul | {string:eq}({abotprop.SUT.GUARANTEED_BIT_RATE_UL})      |
      | bearer_contexts_to_create.0.bearer_qos.guaranteed_bit_rate_dl | {string:eq}({abotprop.SUT.GUARANTEED_BIT_RATE_DL})      |
      | bearer_contexts_to_create.0.s1u_enodeb.fq_teid.interface_type | {string:eq}(0)                                          |
      | bearer_contexts_to_create.0.s1u_enodeb.fq_teid.ipv4_flag      | {string:eq}(1)                                          |
      | bearer_contexts_to_create.0.s1u_enodeb.fq_teid.ipv6_flag      | {string:eq}(0)                                          |
      | bearer_contexts_to_create.0.s1u_enodeb.fq_teid.teid           | save(GTPV1U_DL_TEID_ENB_S1U)                            |
      | bearer_contexts_to_create.0.s1u_enodeb.fq_teid.ipv4_add       | {string:eq}({abotprop.SUT.IPV4_ADDRESS})                |

    When I send GTPV2C message GTPV2C_CREATE_SESSION_REQUEST on interface S5-S8 with the following details from node SGW1 to PGW1:
      | parameter                                                         | value                                      |
      | header.message_type                                               | 32                                         |
      | header.teid                                                       | 0                                          |
      | header.seq_number                                                 | {abotprop.SUT.GTPV2.HEADER.SEQ.NUM.200}    |
      | recovery                                                          | {abotprop.SUT.GTPV2.RECV.RESTART.COUNTER}  |
      | imsi                                                              | $(IMSI)                                    |
      | msisdn                                                            | incr(22331010101010,1)                     |
      | meid                                                              | incr(123456789012345,1)                    |
      | serving_network.mcc                                               | {abotprop.SUT.MCC}                         |
      | serving_network.mnc                                               | {abotprop.SUT.MNC}                         |
      | rat_type                                                          | {abotprop.SUT.GTPV2.RAT.TYPE.EUTRAN}       |
      | indication                                                        | {abotprop.SUT.GTPV2_INDICATION}            |
      | sender_fteid_cntrl_plane.fq_teid.interface_type                   | 6                                          |
      | sender_fteid_cntrl_plane.fq_teid.ipv4_flag                        | {abotprop.SUT.GTPV2.IPV4.PRES}             |
      | sender_fteid_cntrl_plane.fq_teid.ipv6_flag                        | {abotprop.SUT.GTPV2.IPV6.ABS}              |
      | sender_fteid_cntrl_plane.fq_teid.teid                             | incr(100,1)                                |
      | sender_fteid_cntrl_plane.fq_teid.ipv4_add                         | {abotprop.SUT.IPV4_ADDRESS}                |
      | apn                                                               | {abotprop.SUT.3GPP.APN}                    |
      | selection_mode                                                    | {abotprop.SUT.GTPV2.NET.PROV.APN.SNV}      |
      | pdn_type                                                          | {abotprop.SUT.3GPP.PDN_TYPE}               |
      | pdn_address_allocation.pdn_type                                   | {abotprop.SUT.3GPP.PDN_TYPE}               |
      | pdn_address_allocation.pdn_address_and_prefix                     | {abotprop.SUT.PDN_ADDRESS}                 |
      | maxm_apn_restriction.apn_restriction_value                        | {abotprop.SUT.GTPV2.APN.REST.VALUE.PUBLIC} |
      | ambr.apn_ambr_uplink                                              | {abotprop.SUT.MAX_BIT_RATE_UL}             |
      | ambr.apn_ambr_downlink                                            | {abotprop.SUT.MAX_BIT_RATE_DL}             |
      | linked.eps_bearer_id                                              | {abotprop.SUT.3GPP.LINKED.EPS_BEARER_ID1}  |
      | charging_char                                                     | {abotprop.SUT.3GPP.GTPV2C.CHARGING_CHAR}   |
      | protocol_config_options                                           | {abotprop.SUT.GTPV2.PCO}                   |
      | ue_timezone.time_zone                                             | {abotprop.SUT.GTPV2.UE.TIMEZONE}           |
      | ue_timezone.daylight_saving_time                                  | {abotprop.SUT.UE.DAYLIGHT.SAVING.TIME}     |
      | lapi                                                              | {abotprop.SUT.GTPV2.LAPI}                  |
      | bearer_contexts_to_create.0.eps_bearer_id                         | {abotprop.SUT.EBI.0.EPS.BEAR.ID}           |
      | bearer_contexts_to_create.0.bearer_qos.pvi                        | {abotprop.SUT.GTPV2.BEARER_QOS.PVI}        |
      | bearer_contexts_to_create.0.bearer_qos.pl                         | {abotprop.SUT.GTPV2.PGW.BEARER_QOS.PL}     |
      | bearer_contexts_to_create.0.bearer_qos.pci                        | {abotprop.SUT.GTPV2.BER.CTXT.QOS.PCI}      |
      | bearer_contexts_to_create.0.bearer_qos.qci                        | {abotprop.SUT.3GPP.BEARER_QCI}             |
      | bearer_contexts_to_create.0.bearer_qos.max_bit_rate_ul            | {abotprop.SUT.MAX_BIT_RATE_UL}             |
      | bearer_contexts_to_create.0.bearer_qos.max_bit_rate_dl            | {abotprop.SUT.MAX_BIT_RATE_DL}             |
      | bearer_contexts_to_create.0.bearer_qos.guaranteed_bit_rate_ul     | {abotprop.SUT.GUARANTEED_BIT_RATE_UL}      |
      | bearer_contexts_to_create.0.bearer_qos.guaranteed_bit_rate_dl     | {abotprop.SUT.GUARANTEED_BIT_RATE_DL}      |
      | bearer_contexts_to_create.0.s5_or_s8_u_sgw.fq_teid.interface_type | 4                                          |
      | bearer_contexts_to_create.0.s5_or_s8_u_sgw.fq_teid.ipv4_flag      | {abotprop.SUT.GTPV2.IPV4.PRES}             |
      | bearer_contexts_to_create.0.s5_or_s8_u_sgw.fq_teid.ipv6_flag      | {abotprop.SUT.GTPV2.IPV6.ABS}              |
      | bearer_contexts_to_create.0.s5_or_s8_u_sgw.fq_teid.teid           | incr(1,8)                                  |
      | bearer_contexts_to_create.0.s5_or_s8_u_sgw.fq_teid.ipv4_add       | {abotprop.SUT.IPV4_ADDRESS}                |
      | user_location_info.uli_flags                                      | 10                                         |
      | user_location_info.ecgi.plmn_identity.mcc                         | {abotprop.SUT.MCC}                         |
      | user_location_info.ecgi.plmn_identity.mnc                         | {abotprop.SUT.MNC}                         |
      | user_location_info.ecgi.cell_id                                   | {abotprop.SUT.ECGI.CELL.ID1}               |

    Then I receive and validate GTPV2C message GTPV2C_CREATE_SESSION_REQUEST on interface S5-S8 with the following details on node PGW1 from SGW1:
      | parameter                                                         | value                                                   |
      | header.message_type                                               | {string:eq}(32)                                         |
      | header.teid                                                       | {string:eq}(0)                                          |
      | header.seq_number                                                 | {string:eq}({abotprop.SUT.GTPV2.HEADER.SEQ.NUM.200})    |
      | recovery                                                          | {string:eq}({abotprop.SUT.GTPV2.RECV.RESTART.COUNTER})  |
      | imsi                                                              | save(IMSI)                                              |
      | msisdn                                                            | save(MSISDN)                                            |
      | meid                                                              | save(MEID)                                              |
      | serving_network.mcc                                               | {integer:eq}({abotprop.SUT.MCC})                        |
      | serving_network.mnc                                               | {integer:eq}({abotprop.SUT.MNC})                        |
      | rat_type                                                          | {string:eq}({abotprop.SUT.GTPV2.RAT.TYPE.EUTRAN})       |
      | indication                                                        | {string:eq}({abotprop.SUT.GTPV2_INDICATION})            |
      | sender_fteid_cntrl_plane.fq_teid.interface_type                   | {string:eq}(6)                                          |
      | sender_fteid_cntrl_plane.fq_teid.ipv4_flag                        | {string:eq}({abotprop.SUT.GTPV2.IPV4.PRES})             |
      | sender_fteid_cntrl_plane.fq_teid.ipv6_flag                        | {string:eq}({abotprop.SUT.GTPV2.IPV6.ABS})              |
      | sender_fteid_cntrl_plane.fq_teid.teid                             | save(GTPV2C_HDR_DL_TEID_SGW_S5S8)                       |
      | sender_fteid_cntrl_plane.fq_teid.ipv4_add                         | {string:eq}({abotprop.SUT.IPV4_ADDRESS})                |
      | apn                                                               | {string:eq}({abotprop.SUT.3GPP.APN})                    |
      | selection_mode                                                    | {string:eq}({abotprop.SUT.GTPV2.NET.PROV.APN.SNV})      |
      | pdn_type                                                          | {string:eq}({abotprop.SUT.3GPP.PDN_TYPE})               |
      | pdn_address_allocation.pdn_type                                   | {string:eq}({abotprop.SUT.3GPP.PDN_TYPE})               |
      | pdn_address_allocation.pdn_address_and_prefix                     | {string:eq}({abotprop.SUT.PDN_ADDRESS})                 |
      | maxm_apn_restriction.apn_restriction_value                        | {string:eq}({abotprop.SUT.GTPV2.APN.REST.VALUE.PUBLIC}) |
      | ambr.apn_ambr_uplink                                              | {string:eq}({abotprop.SUT.MAX_BIT_RATE_UL})             |
      | ambr.apn_ambr_downlink                                            | {string:eq}({abotprop.SUT.MAX_BIT_RATE_DL})             |
      | linked.eps_bearer_id                                              | {string:eq}({abotprop.SUT.3GPP.LINKED.EPS_BEARER_ID1})  |
      | charging_char                                                     | {string:eq}({abotprop.SUT.3GPP.GTPV2C.CHARGING_CHAR})   |
      | protocol_config_options                                           | {string:eq}({abotprop.SUT.GTPV2.PCO})                   |
      | ue_timezone.time_zone                                             | {string:eq}({abotprop.SUT.GTPV2.UE.TIMEZONE})           |
      | ue_timezone.daylight_saving_time                                  | {string:eq}({abotprop.SUT.UE.DAYLIGHT.SAVING.TIME})     |
      | lapi                                                              | {string:eq}({abotprop.SUT.GTPV2.LAPI})                  |
      | bearer_contexts_to_create.0.eps_bearer_id                         | {string:eq}({abotprop.SUT.3GPP.EPS_BEARER_ID})          |
      | bearer_contexts_to_create.0.bearer_qos.pvi                        | {string:eq}(0)                                          |
      | bearer_contexts_to_create.0.bearer_qos.pl                         | {string:eq}(15)                                         |
      | bearer_contexts_to_create.0.bearer_qos.pci                        | {string:eq}({abotprop.SUT.GTPV2.BER.CTXT.QOS.PCI})      |
      | bearer_contexts_to_create.0.bearer_qos.qci                        | save(QCI)                                               |
      | bearer_contexts_to_create.0.bearer_qos.max_bit_rate_ul            | {string:eq}({abotprop.SUT.MAX_BIT_RATE_UL})             |
      | bearer_contexts_to_create.0.bearer_qos.max_bit_rate_dl            | {string:eq}({abotprop.SUT.MAX_BIT_RATE_DL})             |
      | bearer_contexts_to_create.0.bearer_qos.guaranteed_bit_rate_ul     | {string:eq}({abotprop.SUT.GUARANTEED_BIT_RATE_UL})      |
      | bearer_contexts_to_create.0.bearer_qos.guaranteed_bit_rate_dl     | {string:eq}({abotprop.SUT.GUARANTEED_BIT_RATE_DL})      |
      | bearer_contexts_to_create.0.s5_or_s8_u_sgw.fq_teid.interface_type | {string:eq}(4)                                          |
      | bearer_contexts_to_create.0.s5_or_s8_u_sgw.fq_teid.ipv4_flag      | {string:eq}({abotprop.SUT.GTPV2.IPV4.PRES})             |
      | bearer_contexts_to_create.0.s5_or_s8_u_sgw.fq_teid.ipv6_flag      | {string:eq}({abotprop.SUT.GTPV2.IPV6.ABS})              |
      | bearer_contexts_to_create.0.s5_or_s8_u_sgw.fq_teid.teid           | save(GTPV1U_DL_TEID_SGW_S5S8U)                          |
      | bearer_contexts_to_create.0.s5_or_s8_u_sgw.fq_teid.ipv4_add       | {string:eq}({abotprop.SUT.IPV4_ADDRESS})                |

    When I send DIAMETER message DIA_CREDIT_CONTROL_REQUEST on interface GX with the following details from node PGW1 to PCRF1:
      | parameter                            | value                                |
      | Hop-by-Hop Identifier                | 224                                  |
      | End-to-End Identifier                | 556                                  |
      | Session-Id                           | incr(1559899815,2)                   |
      | DRMP                                 | 1                                    |
      | Auth-Application-Id                  | 16777238                             |
      | Origin-Host                          | {abotprop.SUT.GX.CAPEX.ORIGIN.HOST}  |
      | Origin-Realm                         | {abotprop.SUT.GX.CAPEX.ORIGIN.REALM} |
      | Destination-Realm                    | {abotprop.SUT.GX.CAPEX.DEST.REALM}   |
      | CC-Request-Type                      | 1                                    |
      | CC-Request-Number                    | 1                                    |
      | Credit-Management-Status             | 33                                   |
      | Destination-Host                     | {abotprop.SUT.GX.CAPEX.DEST.HOST}    |
      | Origin-State-Id                      | 31                                   |
      | Subscription-ID.Subscription-ID-Type | 0                                    |
      | Subscription-ID.Subscription-ID-Data | $(IMSI)                              |
      | IP-CAN-Type                          | 5                                    |
      | RAT-Type                             | 1004                                 |
      | QoS-Information.QoS-Class-Identifier | 9                                    |
      | Called-Station-ID                    | {abotprop.SUT.CALLED.STATION.ID}     |
      

    Then I receive and validate DIAMETER message DIA_CREDIT_CONTROL_REQUEST on interface GX with the following details on node PCRF1 from PGW1:
      | parameter                            | value                                             |
      | Hop-by-Hop Identifier                | save(HOP_BY_HOP_ID)                               |
      | End-to-End Identifier                | save(END_TO_END_ID)                               |
      | Session-Id                           | save(DIA_SESS_ID_GX)                              |
      | DRMP                                 | {integer:eq}(1)                                   |
      | Auth-Application-Id                  | {integer:eq}(16777238)                            |
      | Origin-Host                          | {string:eq}({abotprop.SUT.GX.CAPEX.ORIGIN.HOST})  |
      | Origin-Realm                         | {string:eq}({abotprop.SUT.GX.CAPEX.ORIGIN.REALM}) |
      | Destination-Realm                    | {string:eq}({abotprop.SUT.GX.CAPEX.DEST.REALM})   |
      | CC-Request-Type                      | {integer:eq}(1)                                   |
      | CC-Request-Number                    | {integer:eq}(1)                                   |
      | Credit-Management-Status             | {integer:eq}(33)                                  |
      | Destination-Host                     | {string:eq}({abotprop.SUT.GX.CAPEX.DEST.HOST})    |
      | Origin-State-Id                      | {integer:eq}(31)                                  |
      | Subscription-ID.Subscription-ID-Type | {integer:eq}(0)                                   |
      | Subscription-ID.Subscription-ID-Data | save(IMSI)                                        |
      | IP-CAN-Type                          | {integer:eq}(5)                                   |
      | RAT-Type                             | {integer:eq}(1004)                                |
      | QoS-Information.QoS-Class-Identifier | {integer:eq}(9)                                   |
      | Called-Station-ID                    | {integer:eq}({abotprop.SUT.CALLED.STATION.ID})    |

    When I send DIAMETER message DIA_CREDIT_CONTROL_ANSWER on interface GX with the following details from node PCRF1 to PGW1:
      | parameter                                                                                 | value                                   |
      | Hop-by-Hop Identifier                                                                     | $(HOP_BY_HOP_ID)                        |
      | End-to-End Identifier                                                                     | $(END_TO_END_ID)                        |
      | Session-Id                                                                                | $(DIA_SESS_ID_GX)                       |
      | DRMP                                                                                      | 1                                       |
      | Auth-Application-Id                                                                       | 16777238                                |
      | Origin-Host                                                                               | {abotprop.SUT.GX.CAPEX.ORIGIN.HOST}     |
      | Origin-Realm                                                                              | {abotprop.SUT.GX.CAPEX.ORIGIN.REALM}    |
      | Result-Code                                                                               | {abotprop.SUT.3GPP.S6A.DIA_RESULT_CODE} |
      | Experimental-Result.Vendor-Id                                                             | 0                                       |
      | Experimental-Result.Experimental-Result-Code                                              | 255                                     |
      | CC-Request-Type                                                                           | 1                                       |
      | CC-Request-Number                                                                         | 34                                      |
      | IP-CAN-Type                                                                               | 5                                       |
      | QoS-Information.QoS-Class-Identifier                                                      | 9                                       |
      | Charging-Rule-Install.Charging-Correlation-Indicator                                      | 0                                       |
      | Charging-Rule-Install.Charging-Rule-Definition.Charging-Rule-Name                         | rule-1                                  |
      | Charging-Rule-Install.Charging-Rule-Definition.Service-Identifier                         | 23                                      |
      | Charging-Rule-Install.Charging-Rule-Definition.Rating-Group                               | {abotprop.SUT.GY.RATING.GROUP}          |
      | Charging-Rule-Install.Charging-Rule-Definition.Flow-Information.Flow-Description          | 3                                       |
      | Charging-Rule-Install.Charging-Rule-Definition.Flow-Information.ToS-Traffic-Class         | 2345                                    |
      | Charging-Rule-Install.Charging-Rule-Definition.Flow-Information.Packet-Filter-Usage       | 1                                       |
      | Charging-Rule-Install.Charging-Rule-Definition.Flow-Status                                | 2                                       |
      | Charging-Rule-Install.Charging-Rule-Definition.Monitoring-Key                             | incr({abotprop.SUT.MONITORING.KEY},1)   |
      | Charging-Rule-Install.Charging-Rule-Definition.QoS-Information.QoS-Class-Identifier       | 2                                       |
      #| Charging-Rule-Install.Charging-Rule-Definition.QoS-Information.Max-Requested-Bandwidth-UL | 256000                                  |
      #| Charging-Rule-Install.Charging-Rule-Definition.QoS-Information.Max-Requested-Bandwidth-DL | 256000                                  |
      | Charging-Rule-Install.Charging-Rule-Definition.Reporting-Level                            | {abotprop.SUT.GY.REPORTING.LEVEL}       |
      | Charging-Rule-Install.Charging-Rule-Definition.Online                                     | 0                                       |
      | Charging-Rule-Install.Charging-Rule-Definition.Offline                                    | 1                                       |
      | Charging-Rule-Install.Charging-Rule-Definition.Precedence                                 | 1                                       |
      | Charging-Rule-Install.Charging-Rule-Definition.Metering-Method                            | 1                                       |


    Then I receive and validate DIAMETER message DIA_CREDIT_CONTROL_ANSWER on interface GX with the following details on node PGW1 from PCRF1:
      | parameter                                                                                 | value                                                 |
      | Hop-by-Hop Identifier                                                                     | save(HOP_BY_HOP_ID)                                   |
      | End-to-End Identifier                                                                     | save(END_TO_END_ID)                                   |
      | Session-Id                                                                                | save(DIA_SESS_ID_GX)                                  |
      | DRMP                                                                                      | {integer:eq}(1)                                       |
      | Auth-Application-Id                                                                       | {integer:eq}(16777238)                                |
      | Origin-Host                                                                               | {string:eq}({abotprop.SUT.GX.CAPEX.ORIGIN.HOST})      |
      | Origin-Realm                                                                              | {string:eq}({abotprop.SUT.GX.CAPEX.ORIGIN.REALM})     |
      | Result-Code                                                                               | {integer:eq}({abotprop.SUT.3GPP.S6A.DIA_RESULT_CODE}) |
      | Experimental-Result.Vendor-Id                                                             | {integer:eq}(0)                                       |
      | Experimental-Result.Experimental-Result-Code                                              | {integer:eq}(255)                                     |
      | CC-Request-Type                                                                           | {integer:eq}(1)                                       |
      | CC-Request-Type                                                                           | {integer:eq}(1)                                       |
      | CC-Request-Number                                                                         | {integer:eq}(34)                                      |
      | IP-CAN-Type                                                                               | {integer:eq}(5)                                       |
      | QoS-Information.QoS-Class-Identifier                                                      | {integer:eq}(9)                                       |
      | Charging-Rule-Install.Charging-Correlation-Indicator                                      | {integer:eq}(0)                                       |
      | Charging-Rule-Install.Charging-Rule-Definition.Charging-Rule-Name                         | {string:eq}(rule-1)                                   |
      | Charging-Rule-Install.Charging-Rule-Definition.Service-Identifier                         | {integer:eq}(23)                                      |
      | Charging-Rule-Install.Charging-Rule-Definition.Rating-Group                               | save(RATING_GROUP)                                    |
      | Charging-Rule-Install.Charging-Rule-Definition.Flow-Information.Flow-Description          | {string:eq}(3)                                        |
      | Charging-Rule-Install.Charging-Rule-Definition.Flow-Information.ToS-Traffic-Class         | {string:eq}(2345)                                     |
      | Charging-Rule-Install.Charging-Rule-Definition.Flow-Information.Packet-Filter-Usage       | {integer:eq}(1)                                       |
      | Charging-Rule-Install.Charging-Rule-Definition.Flow-Status                                | {integer:eq}(2)                                       |
      | Charging-Rule-Install.Charging-Rule-Definition.Monitoring-Key                             | save(MONITORING_KEY)                                  |
      | Charging-Rule-Install.Charging-Rule-Definition.QoS-Information.QoS-Class-Identifier       | {integer:eq}(2)                                       |
      #| Charging-Rule-Install.Charging-Rule-Definition.QoS-Information.Max-Requested-Bandwidth-UL | {integer:eq}(256000)                                  |
      #| Charging-Rule-Install.Charging-Rule-Definition.QoS-Information.Max-Requested-Bandwidth-DL | {integer:eq}(256000)                                  |
      | Charging-Rule-Install.Charging-Rule-Definition.Reporting-Level                            | {integer:eq}({abotprop.SUT.GY.REPORTING.LEVEL})       |
      | Charging-Rule-Install.Charging-Rule-Definition.Online                                     | {integer:eq}(0)                                       |
      | Charging-Rule-Install.Charging-Rule-Definition.Offline                                    | {integer:eq}(1)                                       |
      | Charging-Rule-Install.Charging-Rule-Definition.Precedence                                 | {integer:eq}(1)                                       |
      | Charging-Rule-Install.Charging-Rule-Definition.Metering-Method                            | {integer:eq}(1)                                       |


    When I send GTPV2C message GTPV2C_CREATE_SESSION_RESPONSE on interface S5-S8 with the following details from node PGW1 to SGW1:
      | parameter                                                       | value                                         |
      | header.message_type                                             | 33                                            |
      | header.teid                                                     | $(GTPV2C_HDR_DL_TEID_SGW_S5S8)                |
      | header.seq_number                                               | {abotprop.SUT.GTPV2.HEADER.SEQ.NUM.200}       |
      | cause.cause_value                                               | {abotprop.SUT.CAUSE.VALUE.REQUEST_ACCEPTED}   |
      | cause.cause_flags                                               | {abotprop.SUT.CAUSE.CAUSE_FLAGS}              |
      | change_reporting_actn                                           | {abotprop.SUT.GTPV2.CHANGE.REPORT.ACTN}       |
      | csg_information_reporting_action.csg_info                       | {abotprop.SUT.GTPV2.CSG.INFO}                 |
      | henb_info_reporting                                             | {abotprop.SUT.GTPV2.HENB.INFO.REPORTING}      |
      | pgw_s5_s8_s2b_gtp_cntrl_plane.fq_teid.interface_type            | 7                                             |
      | pgw_s5_s8_s2b_gtp_cntrl_plane.fq_teid.ipv4_flag                 | {abotprop.SUT.GTPV2.IPV4.PRES}                |
      | pgw_s5_s8_s2b_gtp_cntrl_plane.fq_teid.ipv6_flag                 | {abotprop.SUT.GTPV2.IPV6.ABS}                 |
      | pgw_s5_s8_s2b_gtp_cntrl_plane.fq_teid.teid                      | incr(1,8)                                     |
      | pgw_s5_s8_s2b_gtp_cntrl_plane.fq_teid.ipv4_add                  | {abotprop.SUT.IPV4_ADDRESS}                   |
      | pgw_s5_s8_s2b_gtp_cntrl_plane.fq_teid.ipv6_add                  | {abotprop.SUT.GTPV2.IPV6_ADDRESS}             |
      | pdn_address_allocation.pdn_type                                 | {abotprop.SUT.3GPP.PDN_TYPE}                  |
      | pdn_address_allocation.pdn_address_and_prefix                   | {abotprop.SUT.PDN_ADDRESS}                    |
      | apn_restriction_value                                           | {abotprop.SUT.GTPV2.APN.REST.VALUE.PUBLIC}    |
      | ambr.apn_ambr_uplink                                            | {abotprop.SUT.MAX_BIT_RATE_UL}                |
      | ambr.apn_ambr_downlink                                          | {abotprop.SUT.MAX_BIT_RATE_DL}                |
      | linked.eps_bearer_id                                            | {abotprop.SUT.3GPP.LINKED.EPS_BEARER_ID2}     |
      | protocol_config_options                                         | {abotprop.SUT.GTPV2.PCO}                      |
      | bearer_contexts_created.0.eps_bearer_id                         | {abotprop.SUT.3GPP.EPS_BEARER_ID}             |
      | bearer_contexts_created.0.cause.cause_value                     | {abotprop.SUT.CAUSE.VALUE.REQUEST_ACCEPTED}   |
      | bearer_contexts_created.0.cause.cause_flags                     | {abotprop.SUT.CAUSE.CAUSE_FLAGS}              |
      | bearer_contexts_created.0.s5_or_s8_u_pgw.fq_teid.interface_type | {abotprop.SUT.GTPV2.PGW.S5_S8.INTERFACE_TYPE} |
      | bearer_contexts_created.0.s5_or_s8_u_pgw.fq_teid.ipv4_flag      | {abotprop.SUT.GTPV2.IPV4.PRES}                |
      | bearer_contexts_created.0.s5_or_s8_u_pgw.fq_teid.ipv6_flag      | {abotprop.SUT.GTPV2.IPV6.ABS}                 |
      | bearer_contexts_created.0.s5_or_s8_u_pgw.fq_teid.teid           | incr(1,8)                                     |
      | bearer_contexts_created.0.s5_or_s8_u_pgw.fq_teid.ipv4_add       | {abotprop.SUT.IPV4_ADDRESS}                   |
      | bearer_contexts_created.0.s5_or_s8_u_pgw.fq_teid.ipv46_add      | {abotprop.SUT.GTPV2.IPV6_ADDRESS}             |
      | bearer_contexts_created.0.bearer_qos.pvi                        | {abotprop.SUT.GTPV2.BER.CTXT.QOS.PVI}         |
      | bearer_contexts_created.0.bearer_qos.pl                         | {abotprop.SUT.GTPV2.BER.CTXT.QOS.PL}          |
      | bearer_contexts_created.0.bearer_qos.pci                        | {abotprop.SUT.GTPV2.BER.CTXT.QOS.PCI}         |
      | bearer_contexts_created.0.bearer_qos.qci                        | {abotprop.SUT.GTPV2.BER.CTXT.QOS.QCI}         |
      | bearer_contexts_created.0.bearer_qos.max_bit_rate_ul            | {abotprop.SUT.MAX_BIT_RATE_UL}                |
      | bearer_contexts_created.0.bearer_qos.max_bit_rate_dl            | {abotprop.SUT.MAX_BIT_RATE_DL}                |
      | bearer_contexts_created.0.bearer_qos.guaranteed_bit_rate_ul     | {abotprop.SUT.GUARANTEED_BIT_RATE_UL}         |
      | bearer_contexts_created.0.bearer_qos.guaranteed_bit_rate_dl     | {abotprop.SUT.GUARANTEED_BIT_RATE_DL}         |
      | bearer_contexts_created.0.charging_id                           | {abotprop.SUT.GTPV2.CHARG.ID.111}             |
      | bearer_contexts_created.0.bearer_flags                          | 1                                             |
      | recovery                                                        | {abotprop.SUT.GTPV2.RECV.RESTART.COUNTER}     |
      | charging_gateway_name.fqdn                                      | {abotprop.SUT.CHARGING_GATEWAY_DOMAIN}        |
      | charging_id                                                     | {abotprop.SUT.GTPV2.CHARG.ID.111}             |
      | pgw.fq_csid.node_id_type                                        | 0                                             |
      | pgw.fq_csid.node_id                                             | {abotprop.SUT.IPV4_ADDRESS}                   |
      | pgw.fq_csid.csid                                                | {abotprop.SUT.GTPV2.PGW.FQ.CSID}              |
      | indication                                                      | {abotprop.SUT.GTPV2_INDICATION}               |

    Then I receive and validate GTPV2C message GTPV2C_CREATE_SESSION_RESPONSE on interface S5-S8 with the following details on node SGW1 from PGW1:
      | parameter                                                       | value                                                    |
      | header.message_type                                             | {string:eq}(33)                                          |
      | header.teid                                                     | save(GTPV2C_HDR_DL_TEID_SGW_S5S8)                        |
      | header.seq_number                                               | {string:eq}({abotprop.SUT.GTPV2.HEADER.SEQ.NUM.200})     |
      | cause.cause_value                                               | {string:eq}({abotprop.SUT.CAUSE.VALUE.REQUEST_ACCEPTED}) |
      | cause.cause_flags                                               | {string:eq}({abotprop.SUT.CAUSE.CAUSE_FLAGS})            |
      | change_reporting_actn                                           | {string:eq}({abotprop.SUT.GTPV2.CHANGE.REPORT.ACTN})     |
      | csg_information_reporting_action.csg_info                       | {string:eq}({abotprop.SUT.GTPV2.CSG.INFO})               |
      | pdn_address_allocation.pdn_type                                 | {string:eq}({abotprop.SUT.3GPP.PDN_TYPE})                |
      | pdn_address_allocation.pdn_address_and_prefix                   | {string:eq}({abotprop.SUT.PDN_ADDRESS})                  |
      | apn_restriction_value                                           | {string:eq}({abotprop.SUT.GTPV2.APN.REST.VALUE.PUBLIC})  |
      | ambr.apn_ambr_uplink                                            | {string:eq}({abotprop.SUT.MAX_BIT_RATE_UL})              |
      | ambr.apn_ambr_downlink                                          | {string:eq}({abotprop.SUT.MAX_BIT_RATE_DL})              |
      | linked.eps_bearer_id                                            | {string:eq}({abotprop.SUT.3GPP.LINKED.EPS_BEARER_ID2})   |
      | pgw_s5_s8_s2b_gtp_cntrl_plane.fq_teid.interface_type            | {string:eq}(7)                                           |
      | pgw_s5_s8_s2b_gtp_cntrl_plane.fq_teid.ipv6_flag                 | {string:eq}({abotprop.SUT.GTPV2.IPV6.ABS})               |
      | pgw_s5_s8_s2b_gtp_cntrl_plane.fq_teid.teid                      | save(GTPV2C_HDR_UL_TEID_PGW_S5S8)                        |
      | pgw_s5_s8_s2b_gtp_cntrl_plane.fq_teid.ipv4_add                  | {string:eq}({abotprop.SUT.IPV4_ADDRESS})                 |
      | pgw_s5_s8_s2b_gtp_cntrl_plane.fq_teid.ipv6_add                  | {string:eq}({abotprop.SUT.GTPV2.IPV6_ADDRESS})           |
      | protocol_config_options                                         | {string:eq}({abotprop.SUT.GTPV2.PCO})                    |
      | recovery                                                        | {string:eq}({abotprop.SUT.GTPV2.RECV.RESTART.COUNTER})   |
      | charging_gateway_name.fqdn                                      | {string:eq}({abotprop.SUT.CHARGING_GATEWAY_DOMAIN})      |
      | indication                                                      | {string:eq}({abotprop.SUT.GTPV2_INDICATION})             |
      | charging_id                                                     | {string:eq}({abotprop.SUT.GTPV2.CHARG.ID.111})           |
      | bearer_contexts_created.0.eps_bearer_id                         | {string:eq}({abotprop.SUT.3GPP.EPS_BEARER_ID})           |
      | bearer_contexts_created.0.cause.cause_value                     | {string:eq}({abotprop.SUT.CAUSE.VALUE.REQUEST_ACCEPTED}) |
      | bearer_contexts_created.0.cause.cause_flags                     | {string:eq}({abotprop.SUT.CAUSE.CAUSE_FLAGS})            |
      | bearer_contexts_created.0.bearer_qos.pvi                        | {string:eq}({abotprop.SUT.GTPV2.BER.CTXT.QOS.PVI})       |
      | bearer_contexts_created.0.bearer_qos.pl                         | {string:eq}({abotprop.SUT.GTPV2.BER.CTXT.QOS.PL})        |
      | bearer_contexts_created.0.bearer_qos.pci                        | {string:eq}({abotprop.SUT.GTPV2.BER.CTXT.QOS.PCI})       |
      | bearer_contexts_created.0.bearer_qos.qci                        | {string:eq}({abotprop.SUT.GTPV2.BER.CTXT.QOS.QCI})       |
      | bearer_contexts_created.0.bearer_qos.max_bit_rate_ul            | {string:eq}({abotprop.SUT.MAX_BIT_RATE_UL})              |
      | bearer_contexts_created.0.bearer_qos.max_bit_rate_dl            | {string:eq}({abotprop.SUT.MAX_BIT_RATE_DL})              |
      | bearer_contexts_created.0.bearer_qos.guaranteed_bit_rate_ul     | {string:eq}({abotprop.SUT.GUARANTEED_BIT_RATE_UL})       |
      | bearer_contexts_created.0.bearer_qos.guaranteed_bit_rate_dl     | {string:eq}({abotprop.SUT.GUARANTEED_BIT_RATE_DL})       |
      | bearer_contexts_created.0.charging_id                           | {string:eq}({abotprop.SUT.GTPV2.CHARG.ID.111})           |
      | bearer_contexts_created.0.bearer_flags                          | {string:eq}({abotprop.SUT.GTPV2.BEARER_FLAGS})           |
      | bearer_contexts_created.0.s5_or_s8_u_pgw.fq_teid.interface_type | {string:eq}(5)                                           |
      | bearer_contexts_created.0.s5_or_s8_u_pgw.fq_teid.ipv4_flag      | {string:eq}(1)                                           |
      | bearer_contexts_created.0.s5_or_s8_u_pgw.fq_teid.ipv6_flag      | {string:eq}(0)                                           |
      | bearer_contexts_created.0.s5_or_s8_u_pgw.fq_teid.teid           | save(GTPV1U_UL_TEID_PGW_S5S8U)                           |
      | bearer_contexts_created.0.s5_or_s8_u_pgw.fq_teid.ipv4_add       | {string:eq}({abotprop.SUT.IPV4_ADDRESS})                 |

    When I send GTPV2C message GTPV2C_CREATE_SESSION_RESPONSE on interface S11 with the following details from node SGW1 to MME1:
      | parameter                                                   | value                                      |
      | header.message_type                                         | 33                                         |
      | header.teid                                                 | $(GTPV2C_HDR_DL_TEID_MME_S11)              |
      | header.seq_number                                           | 100                                        |
      | cause.cause_value                                           | 16                                         |
      | cause.cause_flags                                           | 0                                          |
      | change_reporting_actn                                       | 6                                          |
      | csg_information_reporting_action.csg_info                   | 1                                          |
      | henb_info_reporting                                         | 1                                          |
      | sender_fteid_cntrl_plane.fq_teid.interface_type             | 11                                         |
      | sender_fteid_cntrl_plane.fq_teid.ipv4_flag                  | 1                                          |
      | sender_fteid_cntrl_plane.fq_teid.ipv6_flag                  | 0                                          |
      | sender_fteid_cntrl_plane.fq_teid.teid                       | incr(1,1)                                  |
      | sender_fteid_cntrl_plane.fq_teid.ipv4_add                   | {abotprop.SUT.IPV4_ADDRESS}                |
      | sender_fteid_cntrl_plane.fq_teid.ipv6_add                   | 0                                          |
      | pdn_address_allocation.pdn_type                             | {abotprop.SUT.3GPP.PDN_TYPE}               |
      | pdn_address_allocation.pdn_address_and_prefix               | {abotprop.SUT.PDN_ADDRESS}                 |
      | apn_restriction_value                                       | 2                                          |
      | ambr.apn_ambr_uplink                                        | {abotprop.SUT.MAX_BIT_RATE_UL}             |
      | ambr.apn_ambr_downlink                                      | {abotprop.SUT.MAX_BIT_RATE_DL}             |
      | linked.eps_bearer_id                                        | {abotprop.SUT.3GPP.LINKED.EPS_BEARER_ID1}  |
      | protocol_config_options                                     | 0x8080211001000010810600000000830600000000 |
      | bearer_contexts_created.0.eps_bearer_id                     | {abotprop.SUT.3GPP.EPS_BEARER_ID}          |
      | bearer_contexts_created.0.cause.cause_value                 | 16                                         |
      | bearer_contexts_created.0.cause.cause_flags                 | 0                                          |
      | bearer_contexts_created.0.s1u_sgw.fq_teid.interface_type    | 1                                          |
      | bearer_contexts_created.0.s1u_sgw.fq_teid.ipv4_flag         | 1                                          |
      | bearer_contexts_created.0.s1u_sgw.fq_teid.ipv6_flag         | 0                                          |
      | bearer_contexts_created.0.s1u_sgw.fq_teid.teid              | incr(1,8)                                  |
      | bearer_contexts_created.0.s1u_sgw.fq_teid.ipv4_add          | {abotprop.SUT.IPV4_ADDRESS}                |
      | bearer_contexts_created.0.s1u_sgw.fq_teid.ipv46_add         | 0                                          |
      | bearer_contexts_created.0.bearer_qos.pvi                    | 1                                          |
      | bearer_contexts_created.0.bearer_qos.pl                     | 14                                         |
      | bearer_contexts_created.0.bearer_qos.pci                    | 1                                          |
      | bearer_contexts_created.0.bearer_qos.qci                    | 9                                          |
      | bearer_contexts_created.0.bearer_qos.max_bit_rate_ul        | {abotprop.SUT.MAX_BIT_RATE_UL}             |
      | bearer_contexts_created.0.bearer_qos.max_bit_rate_dl        | {abotprop.SUT.MAX_BIT_RATE_DL}             |
      | bearer_contexts_created.0.bearer_qos.guaranteed_bit_rate_ul | {abotprop.SUT.GUARANTEED_BIT_RATE_UL}      |
      | bearer_contexts_created.0.bearer_qos.guaranteed_bit_rate_dl | {abotprop.SUT.GUARANTEED_BIT_RATE_DL}      |
      | bearer_contexts_created.0.charging_id                       | 111                                        |
      | bearer_contexts_created.0.bearer_flags                      | 1                                          |
      | bearer_contexts_created.0.s11_u_sgw.fq_teid.interface_type  | 39                                         |
      | bearer_contexts_created.0.s11_u_sgw.fq_teid.ipv4_flag       | 1                                          |
      | bearer_contexts_created.0.s11_u_sgw.fq_teid.ipv6_flag       | 0                                          |
      | bearer_contexts_created.0.s11_u_sgw.fq_teid.teid            | incr(1,8)                                  |
      | bearer_contexts_created.0.s11_u_sgw.fq_teid.ipv4_add        | {abotprop.SUT.IPV4_ADDRESS}                |
      | bearer_contexts_created.0.s11_u_sgw.fq_teid.ipv46_add       | 0                                          |
      | bearer_contexts_to_remove.0.cause.cause_value               | 16                                         |
      | bearer_contexts_to_remove.0.cause.cause_flags               | 0                                          |
      | bearer_contexts_to_remove.0.eps_bearer_id                   | 5                                          |
      | recovery                                                    | 0                                          |
      | charging_gateway_name.fqdn                                  | {abotprop.SUT.CHARGING_GATEWAY_DOMAIN}     |
      | charging_id                                                 | 111                                        |
      | pgw.fq_csid.node_id_type                                    | 0                                          |
      | pgw.fq_csid.node_id                                         | {abotprop.SUT.IPV4_ADDRESS}                |
      | pgw.fq_csid.csid                                            | 2                                          |
      | sgw.fq_csid.node_id_type                                    | 0                                          |
      | sgw.fq_csid.node_id                                         | {abotprop.SUT.IPV4_ADDRESS}                |
      | sgw.fq_csid.csid                                            | 4                                          |
      | pgw.ldn                                                     | A                                          |
      | sgw.ldn                                                     | B                                          |
      | pgw_back_off_time.epc_timer.timer_unit                      | 2                                          |
      | pgw_back_off_time.epc_timer.timer_value                     | 1                                          |
      | indication                                                  | 0x801801                                   |

    Then I receive and validate GTPV2C message GTPV2C_CREATE_SESSION_RESPONSE on interface S11 with the following details on node MME1 from SGW1:
      | parameter                                                   | value                                                   |
      | header.message_type                                         | {string:eq}(33)                                         |
      | header.teid                                                 | save(GTPV2C_HDR_DL_TEID_MME_S11)                        |
      | header.seq_number                                           | {string:eq}(100)                                        |
      | cause.cause_value                                           | {string:eq}(16)                                         |
      | cause.cause_flags                                           | {string:eq}(0)                                          |
      | change_reporting_actn                                       | {string:eq}(6)                                          |
      | csg_information_reporting_action.csg_info                   | {string:eq}(1)                                          |
      | pdn_address_allocation.pdn_type                             | {string:eq}({abotprop.SUT.3GPP.PDN_TYPE})               |
      | pdn_address_allocation.pdn_address_and_prefix               | {string:eq}({abotprop.SUT.PDN_ADDRESS})                 |
      | apn_restriction_value                                       | {string:eq}(2)                                          |
      | ambr.apn_ambr_uplink                                        | {string:eq}({abotprop.SUT.MAX_BIT_RATE_UL})             |
      | ambr.apn_ambr_downlink                                      | {string:eq}({abotprop.SUT.MAX_BIT_RATE_DL})             |
      | linked.eps_bearer_id                                        | {string:eq}({abotprop.SUT.3GPP.LINKED.EPS_BEARER_ID1})  |
      | sender_fteid_cntrl_plane.fq_teid.interface_type             | {string:eq}(11)                                         |
      | sender_fteid_cntrl_plane.fq_teid.ipv4_flag                  | {string:eq}(1)                                          |
      | sender_fteid_cntrl_plane.fq_teid.ipv6_flag                  | {string:eq}(0)                                          |
      | sender_fteid_cntrl_plane.fq_teid.teid                       | save(GTPV2C_HDR_UL_TEID_SGW_S11)                        |
      | sender_fteid_cntrl_plane.fq_teid.ipv4_add                   | {string:eq}({abotprop.SUT.IPV4_ADDRESS})                |
      | sender_fteid_cntrl_plane.fq_teid.ipv6_add                   | {string:eq}(0)                                          |
      | protocol_config_options                                     | {string:eq}(0x8080211001000010810600000000830600000000) |
      | recovery                                                    | {string:eq}(0)                                          |
      | charging_gateway_name.fqdn                                  | {string:eq}({abotprop.SUT.CHARGING_GATEWAY_DOMAIN})     |
      | pgw_back_off_time.epc_timer.timer_unit                      | {string:eq}(2)                                          |
      | pgw_back_off_time.epc_timer.timer_value                     | {string:eq}(1)                                          |
      | indication                                                  | {string:eq}(0x801801)                                   |
      | charging_id                                                 | {string:eq}(111)                                        |
      | bearer_contexts_created.0.eps_bearer_id                     | {string:eq}({abotprop.SUT.3GPP.EPS_BEARER_ID})          |
      | bearer_contexts_created.0.cause.cause_value                 | {string:eq}(16)                                         |
      | bearer_contexts_created.0.cause.cause_flags                 | {string:eq}(0)                                          |
      | bearer_contexts_created.0.s1u_sgw.fq_teid.interface_type    | {string:eq}(1)                                          |
      | bearer_contexts_created.0.s1u_sgw.fq_teid.ipv4_flag         | {string:eq}(1)                                          |
      | bearer_contexts_created.0.s1u_sgw.fq_teid.ipv6_flag         | {string:eq}(0)                                          |
      | bearer_contexts_created.0.s1u_sgw.fq_teid.teid              | save(GTPV1U_UL_TEID_SGW_S1U)                            |
      | bearer_contexts_created.0.s1u_sgw.fq_teid.ipv4_add          | {string:eq}({abotprop.SUT.IPV4_ADDRESS})                |
      | bearer_contexts_created.0.s1u_sgw.fq_teid.ipv46_add         | {string:eq}(0)                                          |
      | bearer_contexts_created.0.bearer_qos.pvi                    | {string:eq}(1)                                          |
      | bearer_contexts_created.0.bearer_qos.pl                     | {string:eq}(14)                                         |
      | bearer_contexts_created.0.bearer_qos.pci                    | {string:eq}(1)                                          |
      | bearer_contexts_created.0.bearer_qos.qci                    | {string:eq}(9)                                          |
      | bearer_contexts_created.0.bearer_qos.max_bit_rate_ul        | {string:eq}({abotprop.SUT.MAX_BIT_RATE_UL})             |
      | bearer_contexts_created.0.bearer_qos.max_bit_rate_dl        | {string:eq}({abotprop.SUT.MAX_BIT_RATE_DL})             |
      | bearer_contexts_created.0.bearer_qos.guaranteed_bit_rate_ul | {string:eq}({abotprop.SUT.GUARANTEED_BIT_RATE_UL})      |
      | bearer_contexts_created.0.bearer_qos.guaranteed_bit_rate_dl | {string:eq}({abotprop.SUT.GUARANTEED_BIT_RATE_DL})      |
      | bearer_contexts_created.0.charging_id                       | {string:eq}(111)                                        |
      | bearer_contexts_created.0.bearer_flags                      | {string:eq}(1)                                          |
      | bearer_contexts_to_remove.0.cause.cause_value               | {string:eq}(16)                                         |
      | bearer_contexts_to_remove.0.cause.cause_flags               | {string:eq}(0)                                          |
      | bearer_contexts_to_remove.0.eps_bearer_id                   | {string:eq}(5)                                          |

    When I send S1AP message S1_INIT_CTXT_SET_REQ_NAS_ATTACH_ACC_ACTIVATE_DEF_B_REQ on interface S1-MME with the following details from node MME1 to eNodeB1:
      | parameter                                                                                                          | value                                                         |
      | mme_ue_s1ap_id                                                                                                     | $(MME_UE_S1AP_ID)                                             |
      | enb_ue_s1ap_id                                                                                                     | $(ENB_UE_S1AP_ID)                                             |
      | ue_ambr.dl                                                                                                         | {abotprop.SUT.UE.AMBR.DL}                                     |
      | ue_ambr.ul                                                                                                         | {abotprop.SUT.UE.AMBR.UL}                                     |
      | ue_security_capabilities.eea                                                                                       | {abotprop.SUT.SECURITY.CAPABILITY.EEA.CTXT}                   |
      | ue_security_capabilities.eia                                                                                       | {abotprop.SUT.SECURITY.CAPABILITY.EIA.CTXT}                   |
      | security_key                                                                                                       | {abotprop.SUT.SECURITY.KEY}                                   |
      | erab_to_be_setup_list.0.erab_id                                                                                    | {abotprop.SUT.DEF.ERAB.ID}                                    |
      | erab_to_be_setup_list.0.gtp_teid                                                                                   | {abotprop.SUT.DEF.ERAB.GTP.TEID}                              |
      | erab_to_be_setup_list.0.transport_layer_address                                                                    | {abotprop.SUT.DEF.ERAB.TRANSPORT.LAYER.ADDR}                  |
      | erab_to_be_setup_list.0.erab_level_qos.qci                                                                         | {abotprop.SUT.DEF.ERAB.QCI}                                   |
      | erab_to_be_setup_list.0.erab_level_qos.arp.priority_level                                                          | {abotprop.SUT.DEF.ERAB.ARP.PRIORITY.LEVEL}                    |
      | erab_to_be_setup_list.0.erab_level_qos.arp.preemption_vulnerability                                                | {abotprop.SUT.DEF.ERAB.ARP.PREEMPT.VULNERABILITY}             |
      | erab_to_be_setup_list.0.erab_level_qos.arp.preemption_capability                                                   | {abotprop.SUT.DEF.ERAB.ARP.PREEMPT.CAPABILITY}                |
      | erab_to_be_setup_list.0.nas_pdu.protocol_discriminator.emm                                                         | {abotprop.SUT.NAS.PROTO.EMM}                                  |
      | erab_to_be_setup_list.0.nas_pdu.security_header_type.plain                                                         | {abotprop.SUT.NAS.SECURITY.HEAD.PLAIN}                        |
      | erab_to_be_setup_list.0.nas_pdu.security_header_type.protected                                                     | {abotprop.SUT.NAS.SECURITY.HEAD.PROTECTED}                    |
      | erab_to_be_setup_list.0.nas_pdu.security_header_protocol_discriminator                                             | 7                                                             |
      | erab_to_be_setup_list.0.nas_pdu.message_authentication_code                                                        | {abotprop.SUT.NAS.AUTH.CODE}                                  |
      | erab_to_be_setup_list.0.nas_pdu.sequence_number                                                                    | flow_incr({abotprop.SUT.NAS.MME.SEQ.NO.OFFSET},1)             |
      | erab_to_be_setup_list.0.nas_pdu.message_type.emm                                                                   | {abotprop.SUT.NAS.ATTACH.ACC.MSG.EMM}                         |
      | erab_to_be_setup_list.0.nas_pdu.attach_accept.eps_attach_result                                                    | 1                                                             |
      | erab_to_be_setup_list.0.nas_pdu.attach_accept.gprs_timer.unit                                                      | {abotprop.SUT.NAS.ATTACH.ACC.GPRS.TIMER.UNIT}                 |
      | erab_to_be_setup_list.0.nas_pdu.attach_accept.gprs_timer.timer_value                                               | {abotprop.SUT.NAS.ATTACH.ACC.GPRS.TIMER.TIMER.VALUE}          |
      | erab_to_be_setup_list.0.nas_pdu.attach_accept.tai_list.type_of_list                                                | {abotprop.SUT.NAS.TAU.TAI.LIST.TYPE.OF.LIST}                  |
      | erab_to_be_setup_list.0.nas_pdu.attach_accept.tai_list.number_of_elements                                          | {abotprop.SUT.NAS.TAU.TAI.LIST.NO.OF.ELEM}                    |
      | erab_to_be_setup_list.0.nas_pdu.attach_accept.tai_list.mcc                                                         | {abotprop.SUT.MCC}                                            |
      | erab_to_be_setup_list.0.nas_pdu.attach_accept.tai_list.mnc                                                         | {abotprop.SUT.MNC}                                            |
      | erab_to_be_setup_list.0.nas_pdu.attach_accept.tai_list.tac                                                         | {abotprop.SUT.TAC}                                            |
      | erab_to_be_setup_list.0.nas_pdu.esm_message.protocol_discriminator.esm                                             | {abotprop.SUT.NAS.ESM.PROTO.ESM}                              |
      | erab_to_be_setup_list.0.nas_pdu.esm_message.eps_bearer_identity.esm                                                | {abotprop.SUT.NAS.ESM.EPS.ESM}                                |
      | erab_to_be_setup_list.0.nas_pdu.esm_message.pti                                                                    | {abotprop.SUT.NAS.ESM.PTI}                                    |
      | erab_to_be_setup_list.0.nas_pdu.esm_message.message_type.esm                                                       | {abotprop.SUT.NAS.ATTACH.ACC.ACTIVATE.DEF.BEARER.REQ.MSG.ESM} |
      | erab_to_be_setup_list.0.nas_pdu.esm_message.activate_default_eps_bearer_context_request.eps_quality_of_service.qci | {abotprop.SUT.DEF.ERAB.QCI}                                   |
      | erab_to_be_setup_list.0.nas_pdu.esm_message.activate_default_eps_bearer_context_request.apn                        | {abotprop.SUT.PDN.CONNECTIVITY.APN}                           |
      | erab_to_be_setup_list.0.nas_pdu.esm_message.activate_default_eps_bearer_context_request.pdn_type                   | {abotprop.SUT.NAS.ESM.PDN.CON.REQ.PDN.TYPE}                   |
      | erab_to_be_setup_list.0.nas_pdu.esm_message.activate_default_eps_bearer_context_request.pdn_address                | {abotprop.SUT.DEF.ERAB.PDN.ADDR}                              |
      | handover_restriction_list.plmn_identity.mcc                                                                        | 208                                                           |
      | handover_restriction_list.plmn_identity.mnc                                                                        | 94                                                            |
      | handover_restriction_list.equivalent_plmns.0.plmn_identity.mcc                                                     | 208                                                           |
      | handover_restriction_list.equivalent_plmns.0.plmn_identity.mnc                                                     | 94                                                            |
      | handover_restriction_list.forbidden_tas.0.plmn_identity.mcc                                                        | 208                                                           |
      | handover_restriction_list.forbidden_tas.0.plmn_identity.mnc                                                        | 94                                                            |
      | handover_restriction_list.forbidden_tas.0.tacs.0.tac                                                               | 2                                                             |
      | handover_restriction_list.forbidden_las.0.plmn_identity.mcc                                                        | 208                                                           |
      | handover_restriction_list.forbidden_las.0.plmn_identity.mnc                                                        | 94                                                            |
      | handover_restriction_list.forbidden_las.0.lacs.0.lac                                                               | 1                                                             |
      | handover_restriction_list.forbidden_inter_rats                                                                     | 0                                                             |

    Then I receive and validate S1AP message S1_INIT_CTXT_SET_REQ_NAS_ATTACH_ACC_ACTIVATE_DEF_B_REQ on interface S1-MME with the following details on node eNodeB1 from MME1:
      | parameter                                                                                                          | value                                                                      |
      | mme_ue_s1ap_id                                                                                                     | $(MME_UE_S1AP_ID)                                                          |
      | enb_ue_s1ap_id                                                                                                     | $(ENB_UE_S1AP_ID)                                                          |
      | ue_ambr.dl                                                                                                         | save(UE.AMBR.DL)                                                           |
      | ue_ambr.ul                                                                                                         | save(UE.AMBR.UL)                                                           |
      | ue_security_capabilities.eea                                                                                       | {string:eq}({abotprop.SUT.SECURITY.CAPABILITY.EEA.CTXT})                   |
      | ue_security_capabilities.eia                                                                                       | {string:eq}({abotprop.SUT.SECURITY.CAPABILITY.EIA.CTXT})                   |
      | security_key                                                                                                       | {string:eq}({abotprop.SUT.SECURITY.KEY})                                   |
      | erab_to_be_setup_list.0.erab_id                                                                                    | save(ERAB_ID)                                                              |
      | erab_to_be_setup_list.0.gtp_teid                                                                                   | save(GTP_TEID)                                                             |
      | erab_to_be_setup_list.0.transport_layer_address                                                                    | {string:eq}({abotprop.SUT.DEF.ERAB.TRANSPORT.LAYER.ADDR})                  |
      | erab_to_be_setup_list.0.erab_level_qos.qci                                                                         | save(QCI)                                                                  |
      #| erab_to_be_setup_list.0.erab_level_qos.qci                                                                         | {integer:ne}(-1)                                                           |
      | erab_to_be_setup_list.0.erab_level_qos.arp.priority_level                                                          | {string:eq}({abotprop.SUT.DEF.ERAB.ARP.PRIORITY.LEVEL})                    |
      | erab_to_be_setup_list.0.erab_level_qos.arp.preemption_vulnerability                                                | {string:eq}({abotprop.SUT.DEF.ERAB.ARP.PREEMPT.VULNERABILITY})             |
      | erab_to_be_setup_list.0.erab_level_qos.arp.preemption_capability                                                   | {string:eq}({abotprop.SUT.DEF.ERAB.ARP.PREEMPT.CAPABILITY})                |
      | erab_to_be_setup_list.0.nas_pdu.protocol_discriminator.emm                                                         | {string:eq}({abotprop.SUT.NAS.PROTO.EMM})                                  |
      | erab_to_be_setup_list.0.nas_pdu.security_header_type.plain                                                         | {string:eq}({abotprop.SUT.NAS.SECURITY.HEAD.PLAIN})                        |
      | erab_to_be_setup_list.0.nas_pdu.security_header_type.protected                                                     | {string:eq}({abotprop.SUT.NAS.SECURITY.HEAD.PROTECTED})                    |
      | erab_to_be_setup_list.0.nas_pdu.security_header_protocol_discriminator                                             | {string:eq}(7)                                                             |
      | erab_to_be_setup_list.0.nas_pdu.message_authentication_code                                                        | save(NAS_AUTH_CODE)                                                        |
      | erab_to_be_setup_list.0.nas_pdu.sequence_number                                                                    | save(NAS_MME_SEQ_NO)                                                       |
      | erab_to_be_setup_list.0.nas_pdu.message_type.emm                                                                   | {string:eq}({abotprop.SUT.NAS.ATTACH.ACC.MSG.EMM})                         |
      | erab_to_be_setup_list.0.nas_pdu.attach_accept.eps_attach_result                                                    | {string:eq}(1)                                                             |
      | erab_to_be_setup_list.0.nas_pdu.attach_accept.gprs_timer.unit                                                      | {string:eq}({abotprop.SUT.NAS.ATTACH.ACC.GPRS.TIMER.UNIT})                 |
      | erab_to_be_setup_list.0.nas_pdu.attach_accept.gprs_timer.timer_value                                               | {string:eq}({abotprop.SUT.NAS.ATTACH.ACC.GPRS.TIMER.TIMER.VALUE})          |
      | erab_to_be_setup_list.0.nas_pdu.attach_accept.tai_list.type_of_list                                                | {string:eq}({abotprop.SUT.NAS.TAU.TAI.LIST.TYPE.OF.LIST})                  |
      | erab_to_be_setup_list.0.nas_pdu.attach_accept.tai_list.number_of_elements                                          | {string:eq}({abotprop.SUT.NAS.TAU.TAI.LIST.NO.OF.ELEM})                    |
      | erab_to_be_setup_list.0.nas_pdu.attach_accept.tai_list.mcc                                                         | {string:eq}({abotprop.SUT.MCC})                                            |
      | erab_to_be_setup_list.0.nas_pdu.attach_accept.tai_list.mnc                                                         | {string:eq}({abotprop.SUT.MNC})                                            |
      | erab_to_be_setup_list.0.nas_pdu.attach_accept.tai_list.tac                                                         | {string:eq}({abotprop.SUT.TAC})                                            |
      | erab_to_be_setup_list.0.nas_pdu.esm_message.protocol_discriminator.esm                                             | {string:eq}({abotprop.SUT.NAS.ESM.PROTO.ESM})                              |
      | erab_to_be_setup_list.0.nas_pdu.esm_message.eps_bearer_identity.esm                                                | {string:eq}({abotprop.SUT.NAS.ESM.EPS.ESM})                                |
      | erab_to_be_setup_list.0.nas_pdu.esm_message.pti                                                                    | {string:eq}({abotprop.SUT.NAS.ESM.PTI})                                    |
      | erab_to_be_setup_list.0.nas_pdu.esm_message.message_type.esm                                                       | {string:eq}({abotprop.SUT.NAS.ATTACH.ACC.ACTIVATE.DEF.BEARER.REQ.MSG.ESM}) |
      | erab_to_be_setup_list.0.nas_pdu.esm_message.activate_default_eps_bearer_context_request.eps_quality_of_service.qci | save(QCI)                                                                  |
      #| erab_to_be_setup_list.0.nas_pdu.esm_message.activate_default_eps_bearer_context_request.eps_quality_of_service.qci | {integer:ne}(-1)                                                           |
      | erab_to_be_setup_list.0.nas_pdu.esm_message.activate_default_eps_bearer_context_request.apn                        | {string:eq}({abotprop.SUT.PDN.CONNECTIVITY.APN})                           |
      | erab_to_be_setup_list.0.nas_pdu.esm_message.activate_default_eps_bearer_context_request.pdn_type                   | {string:eq}({abotprop.SUT.NAS.ESM.PDN.CON.REQ.PDN.TYPE})                   |
      | erab_to_be_setup_list.0.nas_pdu.esm_message.activate_default_eps_bearer_context_request.pdn_address                | save(ERAB.PDN.ADDR)                                                        |
      | handover_restriction_list.plmn_identity.mcc                                                                        | 208                                                                        |
      | handover_restriction_list.plmn_identity.mnc                                                                        | 94                                                                         |
      | handover_restriction_list.equivalent_plmns.0.plmn_identity.mcc                                                     | 208                                                                        |
      | handover_restriction_list.equivalent_plmns.0.plmn_identity.mnc                                                     | 94                                                                         |
      | handover_restriction_list.forbidden_tas.0.plmn_identity.mcc                                                        | 208                                                                        |
      | handover_restriction_list.forbidden_tas.0.plmn_identity.mnc                                                        | 94                                                                         |
      | handover_restriction_list.forbidden_tas.0.tacs.0.tac                                                               | 2                                                                          |
      | handover_restriction_list.forbidden_las.0.plmn_identity.mcc                                                        | 208                                                                        |
      | handover_restriction_list.forbidden_las.0.plmn_identity.mnc                                                        | 94                                                                         |
      | handover_restriction_list.forbidden_las.0.lacs.0.lac                                                               | 1                                                                          |
      | handover_restriction_list.forbidden_inter_rats                                                                     | 0                                                                          |

    When I send S1AP message S1_INIT_CTXT_SET_RES on interface S1-MME with the following details from node eNodeB1 to MME1:
      | parameter                                 | value                                 |
      | mme_ue_s1ap_id                            | $(MME_UE_S1AP_ID)                     |
      | enb_ue_s1ap_id                            | $(ENB_UE_S1AP_ID)                     |
      | erab_setup_list.0.erab_id                 | {abotprop.SUT.DEF.ERAB.ID}            |
      | erab_setup_list.0.gtp_teid                | {abotprop.SUT.DEF.ERAB.GTP.TEID}      |
      | erab_setup_list.0.transport_layer_address | {abotprop.ABOT.SecureShell.IPAddress} |

    Then I receive and validate S1AP message S1_INIT_CTXT_SET_RES on interface S1-MME with the following details on node MME1 from eNodeB1:
      | parameter                                 | value                                              |
      | mme_ue_s1ap_id                            | $(MME_UE_S1AP_ID)                                  |
      | enb_ue_s1ap_id                            | $(ENB_UE_S1AP_ID)                                  |
      | erab_setup_list.0.erab_id                 | {string:eq}({abotprop.SUT.DEF.ERAB.ID})            |
      | erab_setup_list.0.gtp_teid                | save(GTP_TEID)                                     |
      | erab_setup_list.0.transport_layer_address | {string:eq}({abotprop.ABOT.SecureShell.IPAddress}) |

    When I send S1AP message S1_UPLINK_NAS_ATTACH_COMPLETE_ACTIVATE_DEF_B_ACC on interface S1-MME with the following details from node eNodeB1 to MME1:
      | parameter                                                                                          | value                                            |
      | mme_ue_s1ap_id                                                                                     | $(MME_UE_S1AP_ID)                                |
      | enb_ue_s1ap_id                                                                                     | $(ENB_UE_S1AP_ID)                                |
      | nas_pdu.protocol_discriminator.emm                                                                 | {abotprop.SUT.NAS.PROTO.EMM}                     |
      | nas_pdu.security_header_type.plain                                                                 | {abotprop.SUT.NAS.SECURITY.HEAD.PLAIN}           |
      | nas_pdu.message_type.emm                                                                           | {abotprop.SUT.NAS.ATTACH.COM.MSG.EMM}            |
      | nas_pdu.security_header_type.protected                                                             | {abotprop.SUT.NAS.SECURITY.HEAD.PROTECTED}       |
      | nas_pdu.security_header_protocol_discriminator                                                     | {abotprop.SUT.SECURITY_HEADER_PD}                |
      | nas_pdu.message_authentication_code                                                                | {abotprop.SUT.NAS.AUTH.CODE}                     |
      | nas_pdu.sequence_number                                                                            | flow_incr({abotprop.SUT.NAS.UE.SEQ.NO.OFFSET},1) |
      | nas_pdu.esm_message.protocol_discriminator.esm                                                     | {abotprop.SUT.NAS.ESM.PROTO.ESM}                 |
      | nas_pdu.esm_message.eps_bearer_identity.esm                                                        | 5                                                |
      | nas_pdu.esm_message.pti                                                                            | 1                                                |
      | nas_pdu.esm_message.message_type.esm                                                               | {abotprop.SUT.NAS.ESM.MSG.TYPE.ESM}              |
      | nas_pdu.esm_message.activate_default_eps_bearer_context_accept.pco.configuration_protocol          | {abotprop.SUT.NAS.ESM.PCO.CONFIG.PROTO}          |
      | nas_pdu.esm_message.activate_default_eps_bearer_context_accept.pco.num_protocol_id_or_container_id | {abotprop.SUT.NAS.ESM.PCO.CONFIG.PID.OR.CID}     |
      | eutran_cgi.plmn_identity.mcc                                                                       | {abotprop.SUT.MCC}                               |
      | eutran_cgi.plmn_identity.mnc                                                                       | {abotprop.SUT.MNC}                               |
      | eutran_cgi.cell_id                                                                                 | {abotprop.SUT.CGI.CELL.ID}                       |
      | tai.plmn_identity.mcc                                                                              | {abotprop.SUT.MCC}                               |
      | tai.plmn_identity.mnc                                                                              | {abotprop.SUT.MNC}                               |
      | tai.tac                                                                                            | {abotprop.SUT.TAC}                               |

    Then I receive and validate S1AP message S1_UPLINK_NAS_ATTACH_COMPLETE_ACTIVATE_DEF_B_ACC on interface S1-MME with the following details on node MME1 from eNodeB1:
      | parameter                                                                                          | value                                                     |
      | mme_ue_s1ap_id                                                                                     | $(MME_UE_S1AP_ID)                                         |
      | enb_ue_s1ap_id                                                                                     | $(ENB_UE_S1AP_ID)                                         |
      | nas_pdu.protocol_discriminator.emm                                                                 | {string:eq}({abotprop.SUT.NAS.PROTO.EMM})                 |
      | nas_pdu.security_header_type.plain                                                                 | {string:eq}({abotprop.SUT.NAS.SECURITY.HEAD.PLAIN})       |
      | nas_pdu.message_type.emm                                                                           | {string:eq}({abotprop.SUT.NAS.ATTACH.COM.MSG.EMM})        |
      | nas_pdu.security_header_type.protected                                                             | {string:eq}({abotprop.SUT.NAS.SECURITY.HEAD.PROTECTED})   |
      | nas_pdu.security_header_protocol_discriminator                                                     | {string:eq}({abotprop.SUT.SECURITY_HEADER_PD})            |
      | nas_pdu.message_authentication_code                                                                | save(NAS_AUTH_CODE)                                       |
      | nas_pdu.sequence_number                                                                            | save(NAS_UE_SEQ_NO)                                       |
      | nas_pdu.esm_message.protocol_discriminator.esm                                                     | {string:eq}({abotprop.SUT.NAS.ESM.PROTO.ESM})             |
      | nas_pdu.esm_message.eps_bearer_identity.esm                                                        | {string:eq}(5)                                            |
      | nas_pdu.esm_message.pti                                                                            | {string:eq}(1)                                            |
      | nas_pdu.esm_message.message_type.esm                                                               | {string:eq}({abotprop.SUT.NAS.ESM.MSG.TYPE.ESM})          |
      | nas_pdu.esm_message.activate_default_eps_bearer_context_accept.pco.configuration_protocol          | {string:eq}({abotprop.SUT.NAS.ESM.PCO.CONFIG.PROTO})      |
      | nas_pdu.esm_message.activate_default_eps_bearer_context_accept.pco.num_protocol_id_or_container_id | {string:eq}({abotprop.SUT.NAS.ESM.PCO.CONFIG.PID.OR.CID}) |
      | eutran_cgi.plmn_identity.mcc                                                                       | {integer:eq}({abotprop.SUT.MCC})                          |
      | eutran_cgi.plmn_identity.mnc                                                                       | {integer:eq}({abotprop.SUT.MNC})                          |
      | eutran_cgi.cell_id                                                                                 | {string:eq}({abotprop.SUT.CGI.CELL.ID})                   |
      | tai.plmn_identity.mcc                                                                              | {integer:eq}({abotprop.SUT.MCC})                          |
      | tai.plmn_identity.mnc                                                                              | {integer:eq}({abotprop.SUT.MNC})                          |
      | tai.tac                                                                                            | {integer:eq}({abotprop.SUT.TAC})                          |

    When I send GTPV2C message GTPV2C_MODIFY_BEARER_REQUEST on interface S11 with the following details from node MME1 to SGW1:
      | parameter                                                    | value                             |
      | header.message_type                                          | 34                                |
      | header.teid                                                  | $(GTPV2C_HDR_UL_TEID_SGW_S11)     |
      | header.seq_number                                            | 400                               |
      | meid                                                         | incr(123456789012345,1)           |
      | user_location_info.uli_flags                                 | 8                                 |
      | user_location_info.tai.plmn_identity.mcc                     | {abotprop.SUT.MCC}                |
      | user_location_info.tai.plmn_identity.mnc                     | {abotprop.SUT.MNC}                |
      | user_location_info.tai.tac                                   | {abotprop.SUT.TAC}                |
      | serving_network.mcc                                          | {abotprop.SUT.MCC}                |
      | serving_network.mnc                                          | {abotprop.SUT.MNC}                |
      | rat_type                                                     | 6                                 |
      | indication                                                   | 0x643001                          |
      | ambr.apn_ambr_uplink                                         | {abotprop.SUT.MAX_BIT_RATE_UL}    |
      | ambr.apn_ambr_downlink                                       | {abotprop.SUT.MAX_BIT_RATE_DL}    |
      | delay_dwnlink_packet_notification_request.delay_value        | 2                                 |
      | recovery                                                     | 0                                 |
      | ue_timezone.time_zone                                        | 2                                 |
      | ue_timezone.daylight_saving_time                             | 4                                 |
      | bearer_contexts_to_modify.0.eps_bearer_id                    | {abotprop.SUT.3GPP.EPS_BEARER_ID} |
      | bearer_contexts_to_modify.0.s1_enodeb.fq_teid.interface_type | 0                                 |
      | bearer_contexts_to_modify.0.s1_enodeb.fq_teid.ipv4_flag      | 1                                 |
      | bearer_contexts_to_modify.0.s1_enodeb.fq_teid.ipv6_flag      | 0                                 |
      | bearer_contexts_to_modify.0.s1_enodeb.fq_teid.teid           | incr(1,8)                         |
      | bearer_contexts_to_modify.0.s1_enodeb.fq_teid.ipv4_add       | {abotprop.SUT.IPV4_ADDRESS}       |
      | bearer_contexts_to_modify.0.s1_enodeb.fq_teid.ipv6_add       | 0                                 |
      | bearer_contexts_to_remove.0.eps_bearer_id                    | 5                                 |

    Then I receive and validate GTPV2C message GTPV2C_MODIFY_BEARER_REQUEST on interface S11 with the following details on node SGW1 from MME1:
      | parameter                                                    | value                                          |
      | header.message_type                                          | {string:eq}(34)                                |
      | header.teid                                                  | save(GTPV2C_HDR_UL_TEID_SGW_S11)               |
      | header.seq_number                                            | {string:eq}(400)                               |
      | meid                                                         | save(MEID)                                     |
      | serving_network.mcc                                          | {integer:eq}({abotprop.SUT.MCC})               |
      | serving_network.mnc                                          | {integer:eq}({abotprop.SUT.MNC})               |
      | rat_type                                                     | {string:eq}(6)                                 |
      | indication                                                   | {string:eq}(0x643001)                          |
      | ambr.apn_ambr_uplink                                         | {string:eq}({abotprop.SUT.MAX_BIT_RATE_UL})    |
      | ambr.apn_ambr_downlink                                       | {string:eq}({abotprop.SUT.MAX_BIT_RATE_DL})    |
      | delay_dwnlink_packet_notification_request.delay_value        | {string:eq}(2)                                 |
      | recovery                                                     | {string:eq}(0)                                 |
      | ue_timezone.time_zone                                        | {string:eq}(2)                                 |
      | ue_timezone.daylight_saving_time                             | {string:eq}(4)                                 |
      | bearer_contexts_to_modify.0.eps_bearer_id                    | {string:eq}({abotprop.SUT.3GPP.EPS_BEARER_ID}) |
      | bearer_contexts_to_modify.0.s1_enodeb.fq_teid.interface_type | {string:eq}(0)                                 |
      | bearer_contexts_to_modify.0.s1_enodeb.fq_teid.ipv4_flag      | {string:eq}(1)                                 |
      | bearer_contexts_to_modify.0.s1_enodeb.fq_teid.ipv6_flag      | {string:eq}(0)                                 |
      | bearer_contexts_to_modify.0.s1_enodeb.fq_teid.teid           | save(GTPV1U_DL_TEID_ENB_S1U)                   |
      | bearer_contexts_to_modify.0.s1_enodeb.fq_teid.ipv4_add       | {string:eq}({abotprop.SUT.IPV4_ADDRESS})       |
      | bearer_contexts_to_modify.0.s1_enodeb.fq_teid.ipv6_add       | {string:eq}(0)                                 |
      | bearer_contexts_to_remove.0.eps_bearer_id                    | {string:eq}(5)                                 |

    When I send GTPV2C message GTPV2C_MODIFY_BEARER_RESPONSE on interface S11 with the following details from node SGW1 to MME1:
      | parameter                                                  | value                                      |
      | header.message_type                                        | 35                                         |
      | header.teid                                                | $(GTPV2C_HDR_DL_TEID_MME_S11)              |
      | header.seq_number                                          | 400                                        |
      | cause.cause_value                                          | 16                                         |
      | cause.cause_flags                                          | 0                                          |
      | msisdn                                                     | incr(22331010101010,1)                     |
      | linked.eps_bearer_id                                       | {abotprop.SUT.3GPP.LINKED.EPS_BEARER_ID1}  |
      | ambr.apn_ambr_uplink                                       | {abotprop.SUT.MAX_BIT_RATE_UL}             |
      | ambr.apn_ambr_downlink                                     | {abotprop.SUT.MAX_BIT_RATE_DL}             |
      | apn_restriction_value                                      | 2                                          |
      | protocol_config_options                                    | 0x8080211001000010810600000000830600000000 |
      | bearer_contexts_modified.0.eps_bearer_id                   | {abotprop.SUT.3GPP.EPS_BEARER_ID}          |
      | bearer_contexts_modified.0.cause.cause_value               | 16                                         |
      | bearer_contexts_modified.0.cause.cause_flags               | 0                                          |
      | bearer_contexts_modified.0.s1_sgw.fq_teid.interface_type   | 1                                          |
      | bearer_contexts_modified.0.s1_sgw.fq_teid.ipv4_flag        | 1                                          |
      | bearer_contexts_modified.0.s1_sgw.fq_teid.ipv6_flag        | 0                                          |
      | bearer_contexts_modified.0.s1_sgw.fq_teid.teid             | incr(1,8)                                  |
      | bearer_contexts_modified.0.s1_sgw.fq_teid.ipv4_add         | {abotprop.SUT.IPV4_ADDRESS}                |
      | bearer_contexts_modified.0.s1_sgw.fq_teid.ipv6_add         | 0                                          |
      | bearer_contexts_modified.0.s11u_sgw.fq_teid.interface_type | 39                                         |
      | bearer_contexts_modified.0.s11u_sgw.fq_teid.ipv4_flag      | 1                                          |
      | bearer_contexts_modified.0.s11u_sgw.fq_teid.ipv6_flag      | 0                                          |
      | bearer_contexts_modified.0.s11u_sgw.fq_teid.teid           | incr(1,8)                                  |
      | bearer_contexts_modified.0.s11u_sgw.fq_teid.ipv4_add       | {abotprop.SUT.IPV4_ADDRESS}                |
      | bearer_contexts_modified.0.s11u_sgw.fq_teid.ipv6_add       | 0                                          |
      | bearer_contexts_modified.0.charging_id                     | 0                                          |
      | bearer_contexts_modified.0.bearer_flags                    | 1                                          |
      | bearer_contexts_to_remove.0.eps_bearer_id                  | 5                                          |
      | bearer_contexts_to_remove.0.cause.cause_value              | 16                                         |
      | bearer_contexts_to_remove.0.cause.cause_flags              | 0                                          |
      | change_reporting_actn                                      | 6                                          |
      | csg_information_reporting_action.csg_info                  | 1                                          |
      | charging_gateway_name.fqdn                                 | {abotprop.SUT.CHARGING_GATEWAY_DOMAIN}     |
      | indication                                                 | 0x801801                                   |

    Then I receive and validate GTPV2C message GTPV2C_MODIFY_BEARER_RESPONSE on interface S11 with the following details on node MME1 from SGW1:
      | parameter                                                  | value                                                   |
      | header.message_type                                        | {string:eq}(35)                                         |
      | header.teid                                                | save(GTPV2C_HDR_DL_TEID_MME_S11)                        |
      | header.seq_number                                          | {string:eq}(400)                                        |
      | cause.cause_value                                          | {string:eq}(16)                                         |
      | cause.cause_flags                                          | {string:eq}(0)                                          |
      | msisdn                                                     | save(MSISDN)                                            |
      | linked.eps_bearer_id                                       | {string:eq}({abotprop.SUT.3GPP.LINKED.EPS_BEARER_ID1})  |
      | ambr.apn_ambr_uplink                                       | {string:eq}({abotprop.SUT.MAX_BIT_RATE_UL})             |
      | ambr.apn_ambr_downlink                                     | {string:eq}({abotprop.SUT.MAX_BIT_RATE_DL})             |
      | apn_restriction_value                                      | {string:eq}(2)                                          |
      | protocol_config_options                                    | {string:eq}(0x8080211001000010810600000000830600000000) |
      | bearer_contexts_modified.0.eps_bearer_id                   | {string:eq}({abotprop.SUT.3GPP.EPS_BEARER_ID})          |
      | bearer_contexts_modified.0.cause.cause_value               | {string:eq}(16)                                         |
      | bearer_contexts_modified.0.cause.cause_flags               | {string:eq}(0)                                          |
      | bearer_contexts_modified.0.s1_sgw.fq_teid.interface_type   | {string:eq}(1)                                          |
      | bearer_contexts_modified.0.s1_sgw.fq_teid.ipv4_flag        | {string:eq}(1)                                          |
      | bearer_contexts_modified.0.s1_sgw.fq_teid.ipv6_flag        | {string:eq}(0)                                          |
      | bearer_contexts_modified.0.s1_sgw.fq_teid.teid             | save(GTPV1U_UL_TEID_SGW_S1U)                            |
      | bearer_contexts_modified.0.s1_sgw.fq_teid.ipv4_add         | {string:eq}({abotprop.SUT.IPV4_ADDRESS})                |
      | bearer_contexts_modified.0.s1_sgw.fq_teid.ipv6_add         | {string:eq}(0)                                          |
      | bearer_contexts_modified.0.s11u_sgw.fq_teid.interface_type | {string:eq}(39)                                         |
      | bearer_contexts_modified.0.s11u_sgw.fq_teid.ipv4_flag      | {string:eq}(1)                                          |
      | bearer_contexts_modified.0.s11u_sgw.fq_teid.ipv6_flag      | {string:eq}(0)                                          |
      | bearer_contexts_modified.0.s11u_sgw.fq_teid.teid           | save(GTPV2C_HDR_DL_TEID_SGW_S11U)                       |
      | bearer_contexts_modified.0.s11u_sgw.fq_teid.ipv4_add       | {string:eq}({abotprop.SUT.IPV4_ADDRESS})                |
      | bearer_contexts_modified.0.s11u_sgw.fq_teid.ipv6_add       | {string:eq}(0)                                          |
      | bearer_contexts_modified.0.charging_id                     | {string:eq}(0)                                          |
      | bearer_contexts_modified.0.bearer_flags                    | {string:eq}(1)                                          |
      | bearer_contexts_to_remove.0.eps_bearer_id                  | {string:eq}(5)                                          |
      | bearer_contexts_to_remove.0.cause.cause_value              | {string:eq}(16)                                         |
      | bearer_contexts_to_remove.0.cause.cause_flags              | {string:eq}(0)                                          |
      | change_reporting_actn                                      | {string:eq}(6)                                          |
      | csg_information_reporting_action.csg_info                  | {string:eq}(1)                                          |
      | charging_gateway_name.fqdn                                 | {string:eq}({abotprop.SUT.CHARGING_GATEWAY_DOMAIN})     |
      | indication                                                 | {string:eq}(0x801801)                                   |

    Then I finish load scenario within 60 Seconds on interface S1-MME,S5-S8,S11,S6A,GX with the following parameters and wait to generate report:
      | parameter     | value          |
      | load-test-nsa | initial-attach |
