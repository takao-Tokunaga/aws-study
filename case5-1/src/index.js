const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const {
  DynamoDBDocumentClient,
  ScanCommand,
} = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({ region: "ap-northeast-1" });
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
  const tableName = process.env.TABLE_NAME;
  const result = await docClient.send(
    new ScanCommand({
      TableName: tableName,
    }),
  );

  return {
    statusCode: 200,
    headers: {
      "Access-Control-Allow-Origin": "http://localhost:5173",
      "Access-Control-Allow-Headers": "Content-Type,Authorization",
    },
    body: JSON.stringify({ items: result.Items }),
  };
};
