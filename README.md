IntoPage
Intro Page (Start Screen):
Description: Intro Page is the first screen that greets a new user. On this screen, the user is given the choice of either registration (if this is a new user, or login, if the user is already registered)
Features:
Button for going to the registration or login screen.
Animations and illustrations that make the introductory acquaintance pleasant and intuitive.

![Screenshot 2024-08-25 164547](https://github.com/user-attachments/assets/e35ae5a8-e7b8-44cc-a0e3-d133d4b5dfd0)





RegistrationScreen
Register Screen:
Description: This screen allows a new user to create an account. The user needs to enter their name, email address, password, and confirm the password. It also checks for uniqueness of the email and name.
Features:
Fields for entering name, email, and password.
A button to complete the registration.
Checks for matching passwords and errors in the form.
Saves user data to the Firestore database.
Proceeds to the email verification screen after successful registration.

![Screenshot 2024-08-25 164601](https://github.com/user-attachments/assets/60771b7b-e054-4b19-a6fa-23a6482e34ab)




VerifyEmail
Verify Email Screen:
Description: After successful registration, the user is taken to the email verification screen. Here, they are asked to confirm their email by clicking on a link sent to the specified email address.
Features:
Sending an email for confirmation.
Instructions for account verification.
Button for resending the email (if the email has not arrived).
Transition to the screen with filling in account fields, such as: phone number, gender, and display name in the application

![Screenshot 2024-08-25 164717](https://github.com/user-attachments/assets/7ef1bbf7-e7bf-4ac2-a65e-c11e6a467bb8)
![Screenshot 2024-08-25 164733](https://github.com/user-attachments/assets/a556ccb6-cf70-4333-b7e9-eab68483805a)
![Screenshot 2024-08-25 164740](https://github.com/user-attachments/assets/c151f461-e99e-46ef-a544-cddf9d774cf9)






Additional Info
Description: After confirming the email, the user is redirected to the add more information screen. Here, the user is asked to enter additional information such as phone number, gender, and display name that will be used in the app.
Features:
Fields for entering phone number and display name.
Drop-down list for selecting gender.
Button to complete entering information and go to the main screen of the app.
Saves the entered information in the Firestore database and updates the user profile in Firebase Auth.

![Screenshot 2024-08-25 164756](https://github.com/user-attachments/assets/9e6db6f3-86a3-473d-9172-8529f8deb70c)
![Screenshot 2024-08-25 164813](https://github.com/user-attachments/assets/8c61560c-b4ab-4734-bf01-9bd6fb4a6e00)
![Screenshot 2024-08-25 164823](https://github.com/user-attachments/assets/d9090ff7-e28c-4c44-931f-ab13e3937782)


Login
Description: The login screen allows the user to log into his account (if the account has been created) by entering the login and password manually, or through a Google account. There are also password reset buttons that take you to the password reset screen and a registration button that takes you to the registration screen.

![Screenshot 2024-08-25 164608](https://github.com/user-attachments/assets/7fb24d8e-b6d2-48ff-8804-94d3bd9543f5)
![Screenshot 2024-08-25 164614](https://github.com/user-attachments/assets/d9c11177-0f1b-44b2-b251-22f51407fb81)
![Screenshot 2024-08-25 164608](https://github.com/user-attachments/assets/ccd42bb3-b89f-4cf6-8201-946a29cbb712)




homePage
Description: The main screen is the main feed with user posts. The user can view posts, leave comments, like them, and if it is a post by a user who is currently in the system, he can delete it.
Features:
Displaying a feed of posts with the ability to interact (likes, comments).
A button for creating a new post that redirects to the post creation screen.
The ability to go to post comments and interact with them (copy the text of a comment, delete your own comment).
The ability to delete your own posts.
Viewing the full version of images published in posts.


![Screenshot 2024-08-25 164842](https://github.com/user-attachments/assets/db1edd1c-4c5b-414b-80f3-d616f18b7468)
![Screenshot 2024-08-25 164853](https://github.com/user-attachments/assets/5bf0598b-9c53-440f-ac6e-7f2ac03c465e)

createPostScreen

![Screenshot 2024-08-25 164909](https://github.com/user-attachments/assets/a54f2a1f-2f48-4c92-adea-6aa507a4cab5)
![Screenshot 2024-08-25 164917](https://github.com/user-attachments/assets/f1431fd4-29d6-4bca-8dc7-24922b13a6ed)


Chat
Description: The chat screen allows the user to communicate with other users of the application. The user can send text messages, files and repost publications from the feed.
Features:
Display a list of messages with the ability to reply, copy and delete (with a long press on the message).
Enter the text of the message at the bottom of the screen with the ability to send.
The ability to attach files and send them in the chat.
Show the reply to the message (quote) and go to the original message by tapping.
Show the time the message was sent

![Screenshot 2024-08-25 164923](https://github.com/user-attachments/assets/07e103aa-b0a1-464e-afd2-605fa0bac0be)
![Screenshot 2024-08-25 164928](https://github.com/user-attachments/assets/a47bb990-1be5-45c7-b760-0a41a7f3813a)
![Screenshot 2024-08-25 164958](https://github.com/user-attachments/assets/0f6a260a-abbd-4d71-b171-d73a5e008bcb)
![Screenshot 2024-08-25 165004](https://github.com/user-attachments/assets/8cb6515c-6c81-49dd-9906-ae48e8f32324)





music

![Screenshot 2024-08-25 165016](https://github.com/user-attachments/assets/6d59ab99-7c6f-4c80-b938-9f6a5efd7f42)

![Screenshot 2024-08-25 165026](https://github.com/user-attachments/assets/056b9a4d-4b63-4f8c-9705-57dc43a2c5f5)
![Screenshot 2024-08-25 165031](https://github.com/user-attachments/assets/c4bea54c-ea9e-4192-ba19-0ca51ce91182)

profile
Description: The profile screen displays user information such as name, status, phone number, and shows all posts created by the user. The user can edit their personal information, add or change their profile photo, and view their activity information.
Features:
View and edit profile information (name, status, phone number).
Upload and update profile photo.
View a list of posts created by the user, with the ability to edit and delete them.
Ability to log out of the account.

![Screenshot 2024-08-25 165038](https://github.com/user-attachments/assets/50d35608-3159-46a9-84a3-9c9ce982ed6b)
![Screenshot 2024-08-25 165554](https://github.com/user-attachments/assets/c4c85b78-9102-47d0-a188-c3e61f08fce2)

user details can be changed inside the app and it will save in DB.



![Screenshot 2024-08-25 165601](https://github.com/user-attachments/assets/66b709e8-1b4d-414a-bec1-8549b7ea3cb8)
![Screenshot 2024-08-25 165050](https://github.com/user-attachments/assets/8f686bec-d1c2-45e5-8457-9f1f25581ae3)

blackTheme&localization
Description: This part of the settings screen allows the user to select the preferred interface language and the application theme (light or dark).
Features:
Drop-down menu for selecting the language.
Switch for selecting the theme (light/dark).
Automatically apply the selected settings to the entire application interface.

![Screenshot 2024-08-25 165659](https://github.com/user-attachments/assets/588c7716-5f02-4033-8ab4-0951b4184e86)
![Screenshot 2024-08-25 165655](https://github.com/user-attachments/assets/3fe78f3e-8097-4038-b59d-1e2199269d82)
![Screenshot 2024-08-25 165648](https://github.com/user-attachments/assets/fce05300-9f73-45e0-8ab2-3e6a4569f6cb)
![Screenshot 2024-08-25 165644](https://github.com/user-attachments/assets/300704d8-5fac-4cd9-b344-89147fa2427a)
![Screenshot 2024-08-25 165635](https://github.com/user-attachments/assets/59d44364-a2d1-4859-b558-1d93e519b579)
![Screenshot 2024-08-25 165627](https://github.com/user-attachments/assets/1d3539ae-fe0b-4a67-81d0-10a5f8b6ee7c)
![Screenshot 2024-08-25 165623](https://github.com/user-attachments/assets/2be65bb9-80d0-4ccf-84ba-b01c419e4156)
![Screenshot 2024-08-25 165619](https://github.com/user-attachments/assets/2c43544e-48e1-4723-a37f-2b3ee1da7699)
![Screenshot 2024-08-25 165613](https://github.com/user-attachments/assets/e2eaccb9-7116-40db-9e4b-ac6b526ad829)
![Screenshot 2024-08-25 165707](https://github.com/user-attachments/assets/bd7daf9a-6a7e-49d1-aa2c-760b1acb78e8)
![image](https://github.com/user-attachments/assets/36b2a43d-9653-494c-aa60-0e03ab40893b)





resetPas

![Screenshot 2024-08-25 170840](https://github.com/user-attachments/assets/4f97d6fb-b735-4b0e-af00-9d3d1dfbd29c)
![Screenshot 2024-08-25 170821](https://github.com/user-attachments/assets/d889a4b8-9753-41fd-9ab8-beaf5e6c737e)
![Screenshot 2024-08-25 170814](https://github.com/user-attachments/assets/bc4b06d3-2c3d-4993-9d62-863b85ada8eb)
![Screenshot 2024-08-25 170905](https://github.com/user-attachments/assets/7e86d3c9-3b24-4291-846e-1dae84a2e554)

sortingMusic



![Screenshot 2024-08-25 170940](https://github.com/user-attachments/assets/c170625a-0b77-42ee-83d4-dfb2319141e3)
![Screenshot 2024-08-25 170956](https://github.com/user-attachments/assets/bf9048b5-652f-4ba8-964e-013ec4e7a2b7)

mistakesFromUsers
![Screenshot 2024-08-25 171137](https://github.com/user-attachments/assets/91fee0a3-5a52-4827-b0e5-cb686a6934e4)
![Screenshot 2024-08-25 171147](https://github.com/user-attachments/assets/3fd37d7f-ae63-4ffd-a3e8-a529a47d271d)

If the user is not registred, he can't reset his password.



![Screenshot 2024-08-25 171058](https://github.com/user-attachments/assets/43093c3e-cd82-4b5f-99e5-ee7864ca9d74)

User can't register second time with the same email.




![Screenshot 2024-08-25 171035](https://github.com/user-attachments/assets/d744f69b-9c51-43a9-b381-78125c26d8b0)
