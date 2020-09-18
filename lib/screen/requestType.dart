enum RequestType{ ATTESTATION_REQUEST, PERSONAL_INFORMATION_REQUEST, FAKE_PERSONAL_INFORMATION_REQUEST, LOGIN}


Map<RequestType, dynamic> AuthenticatorActions = {
  RequestType.ATTESTATION_REQUEST: {
    "NAME": "Attestate",
    "DATA": [
      "Country (SOD)",
      "Passport Public Key (DG15)",
      "Passport Signature"
    ],
    "TEXT_ON_SUCCESS": "Well done, your transaction is published. You are now attested as Anonymous."
  },
  RequestType.PERSONAL_INFORMATION_REQUEST: {
    "NAME": "Send Personal Info",
    "DATA": ["Personal Information (DG1))", "Passport Signature"],
    "TEXT_ON_SUCCESS": "Well done, your personal data  was successfully send."
  },
  RequestType.FAKE_PERSONAL_INFORMATION_REQUEST: {
    "NAME": "Send Fake Personal Info",
    "DATA": ["Personal Information (DG1)", "Passport Signature)"],
    "TEXT_ON_SUCCESS": "Well done, your personal data  was successfully send."
  },
  RequestType.LOGIN: {
    "NAME": "Login",
    "DATA": ["Passport Signature"],
    "TEXT_ON_SUCCESS": "Well done, you are successfully logged in."
  },
};