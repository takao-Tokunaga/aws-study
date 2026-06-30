import { CognitoIdentityProviderClient } from "@aws-sdk/client-cognito-identity-provider";

export const cognitoClient = new CognitoIdentityProviderClient({
  region: "ap-northeast-1",
});

export const CLIENT_ID = "2anlsgoiks0fg1v4vb7n1t7mjn";
