Hi Team,

Just a quick heads-up on what Frank will be working on. He’s planning to set up a private GitHub App in our sandbox GitHub Enterprise environment. This will be used specifically for testing and setting up a secure integration with LibreView’s GitHub instance. No repos will be created — it’s all about getting the connection in place first.

Once the app is set up, it’ll generate the usual artifacts like the .pem file, App ID, Client ID, and Client Secret. These will be used by LibreView to authorize access securely, and nothing will be shared in plain text.

The idea is to move towards automated, app-based authentication instead of using individual accounts — that way, we get better scalability and security. For access, we’ll likely need read-only permissions to the COBOL repo and read-write for the modern codebase (Java, Bash, etc.). This might mean setting up two apps with different scopes.

Frank also plans to automate the token generation and connection flow to make the process secure and repeatable. He’ll update the documentation as he goes, and we’ll sync internally before taking any major steps.
