enum RequestType{ ATTESTATION_REQUEST, ATTESTATION_REQUEST_WITH_DG1, ATTESTATION_REQUEST_WITH_DG1_AND_DG2, PERSONAL_INFORMATION_REQUEST, FAKE_PERSONAL_INFORMATION_REQUEST, LOGIN}


Map<RequestType, dynamic> AuthenticatorActions = {
  RequestType.ATTESTATION_REQUEST: {
    "NAME": "Attest",
    "DATA": [
      "Passport authn data & Country (EF.SOD)",
      "Passport Public Key (EF.DG15)",
      "Passport Signature"
    ],
    "DATA_IN_REVIEW": [
      "Passport authn data & Country (EF.SOD)",
      "Passport Public Key (EF.DG15)",
      "Passport Signature"
    ],
    "TEXT_ON_SUCCESS": "Well done, you are now anonymously attested!",
    "IS_PUBLISHED_ON_CHAIN": true
  },
  RequestType.ATTESTATION_REQUEST_WITH_DG1: {
    "NAME": "Personal Info",
    "DATA": [
      "Passport authn data & Country (EF.SOD)",
      "Personal Data (EF.DG1)",
      "Passport Public Key (EF.DG15)",
      "Passport Signature"
    ],
    "DATA_IN_REVIEW": [
      "Passport authn data & Country (EF.SOD)",
      "Personal Data (EF.DG1)",
      "Passport Public Key (EF.DG15)",
      "Passport Signature"
    ],
    "TEXT_ON_SUCCESS": "Well done, you are now registered!",
    "IS_PUBLISHED_ON_CHAIN": false
  },
  RequestType.ATTESTATION_REQUEST_WITH_DG1_AND_DG2: {
    "NAME": "Personal Info & Picture",
    "DATA": [
      "Passport authn data & Country (EF.SOD)",
      "Personal Data (EF.DG1)",
      "Portret (EF.DG2)",
      "Passport Public Key (EF.DG15)",
      "Passport Signature"
    ],
    "DATA_IN_REVIEW": [
      "Passport authn data & Country (EF.SOD)",
      "Personal Data (EF.DG1)",
      "Portret (EF.DG2)",
      "Passport Public Key (EF.DG15)",
      "Passport Signature"
    ],
    "TEXT_ON_SUCCESS": "Well done, you are now registered!",
    "IS_PUBLISHED_ON_CHAIN": false
  },
  RequestType.PERSONAL_INFORMATION_REQUEST: {
    "NAME": "Send Personal Info",
    "DATA": ["Personal Information (DG1)", "Passport Signature"],
    "DATA_IN_REVIEW": ["Passport Signature"],
    "TEXT_ON_SUCCESS": "Well done, your personal data  was successfully send!",
    "IS_PUBLISHED_ON_CHAIN": false
  },
  RequestType.FAKE_PERSONAL_INFORMATION_REQUEST: {
    "NAME": "Send Fake Personal Info",
    "DATA": ["Personal Information (EF.DG1)", "Passport Signature)"],
    "DATA_IN_REVIEW": ["Passport Signature"],
    "TEXT_ON_SUCCESS": "Well done, your personal data  was successfully send!",
    "IS_PUBLISHED_ON_CHAIN": false
  },
  RequestType.LOGIN: {
    "NAME": "Authentication",
    "DATA": ["Passport Signature"],
    "DATA_IN_REVIEW": ["Passport Signature"],
    "TEXT_ON_SUCCESS": "Well done, you are successfully logged in.",
    "IS_PUBLISHED_ON_CHAIN": false
  },
};

Map<int, RequestType> numericToRequestType = {
  1: RequestType.ATTESTATION_REQUEST,
  2: RequestType.ATTESTATION_REQUEST_WITH_DG1,
  3: RequestType.ATTESTATION_REQUEST_WITH_DG1_AND_DG2,
  4: RequestType.PERSONAL_INFORMATION_REQUEST,
  5: RequestType.FAKE_PERSONAL_INFORMATION_REQUEST,
  6: RequestType.LOGIN,
};

