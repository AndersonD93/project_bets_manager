const config = {
    development: {
      apiUrlSecrets: 'https://vj8nf8d3sl.execute-api.us-east-1.amazonaws.com/v1/get_secret'
    },
    production: {
      apiUrlSecrets: 'https://vj8nf8d3sl.execute-api.us-east-1.amazonaws.com/v1/get_secret'
    }
  };
  
  const environment = 'development';
  
  export default config[environment];
  