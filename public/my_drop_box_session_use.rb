# 1. Create a new record (account email is optional)
@db_session = MyDropboxSession.create({app_key: MyDropboxSession::APP_KEY, 
                                        app_secret: MyDropboxSession::APP_SECRET, 
                                        account_email: "a_dropbox_email@example.com"})  
 
# 2. Get the authorization url and visit it in your browser and then authorize the Application
@db_session.authorization_url
 
# 3. After authorizing in the browser, complete the authorization
# - This gets the access token, serializes the session and saves it in the database
@db_session.complete_authorization
 
# 4. Use the client to your heart's content
@db_session.client.metadata "/"
 
# Next time:
# 1. Recovering the session is automatic when you load the active record
#@db_session = TupDropboxSession.authorized.where(account_email: "a_dropbox_email@example.com").last
 
# 2. Use the client
#@db_session.client.metadata "/"