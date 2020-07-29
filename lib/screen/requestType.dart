enum RequestType{ ATTESTATION_REQUEST, PERSONAL_INFORMATION_REQUEST, FAKE_PERSONAL_INFORMATION_REQUEST, LOGIN}


Map<RequestType, dynamic> AuthenticatorActions = {
  RequestType.ATTESTATION_REQUEST: {
    "NAME": "Attestate",
    "DATA": [
      "Country (SOD)",
      "Passport Public Key (DG15)",
      "Passport Signature"
    ]
  },
  RequestType.PERSONAL_INFORMATION_REQUEST: {
    "NAME": "Send Personal Info",
    "DATA": ["Personal Information (DG1))", "Passport Signature"]
  },
  RequestType.FAKE_PERSONAL_INFORMATION_REQUEST: {
    "NAME": "Send Fake Personal Info",
    "DATA": ["Personal Information (DG1)", "Passport Signature)"]
  },
  RequestType.LOGIN: {
    "NAME": "Login",
    "DATA": ["Passport Signature"]
  },
};