<div align="center">
  <img src="/Twitter.png" width=200 height=200>
  <h1>Twitter Clone Application</h1>
  <img src="https://img.shields.io/github/last-commit/Chamepp/Twitter-Clone">
  <img src="https://img.shields.io/github/issues-raw/Chamepp/Twitter-Clone?color=magenta">
  <img src="https://img.shields.io/github/issues-pr/Chamepp/Twitter-Clone?color=purple">
  <img src="https://img.shields.io/github/stars/Chamepp/Twitter-Clone?style=social">
  <img src="https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Fgithub.com%2FChamepp%2FTwitter-Clone">
  <p>
  A clone version of the twitter application built in UIKit.
  </p>
</div>

## Technologies & Patterns

- **UIKit**
    - I developed the app using UIKit because I needed more experience with the framework. Additionally, UIKit is more mature, and I found its development cycle and workflow more enjoyable compared to SwiftUI. SwiftUI, while promising, is still evolving and has some production-stage issues due to its rapid updates, making UIKit a more stable choice for this project.
- **Firebase**
    - We had experience using Core Data and User Defaults for local data storage but wanted to expand our knowledge by learning Firebase for cloud-based services. Firebase was chosen for its robust, real-time data synchronization across devices, built-in authentication services, and serverless architecture. It simplifies backend management by offering integrated services like database (Firestore), file storage, and user authentication, all with minimal setup. Additionally, Firebase’s scalability, security features, and real-time database capabilities make it an ideal solution for handling dynamic data in real-time applications like social media apps.
- **MVVM**
    - I implemented the MVVM (Model-View-ViewModel) pattern for this project because it provides a clearer separation of concerns compared to the traditional MVC (Model-View-Controller) pattern. In larger projects, like this social media app, MVC can result in “Massive View Controllers,” where too much logic is handled by the controller, making it harder to maintain and test. MVVM decouples the UI from the business logic, placing the business logic in the ViewModel, which improves testability, modularity, and allows for easier code maintenance. The reactive nature of MVVM also helps in managing dynamic UI updates more efficiently.
- **Singleton Design Pattern**
    - Although we don’t have extensive knowledge about design patterns yet, we discovered that the Singleton pattern fits perfectly with the MVVM architecture. It helps us keep a cleaner codebase by ensuring that only a single instance of certain classes (like network managers, authentication services, or database handlers) exists throughout the app. This pattern prevents unnecessary duplication of objects and reduces memory overhead. Additionally, the Singleton pattern provides a global point of access to these services, making it easier to manage resources and simplifying the integration with other parts of the app, especially in scenarios where shared state or dependencies are involved.
- **Protocol-Oriented Development**
    - We chose Protocol-Oriented Programming (POP) because it helps us create a cleaner, more modular codebase by defining behavior contracts through protocols rather than relying heavily on class inheritance. This approach makes the app more scalable, as it allows for easier extension and composition of functionality across different parts of the app. POP promotes code reusability and flexibility, enabling us to build small, focused components that can be reused and combined to meet the needs of different parts of the project. Additionally, it aligns well with Swift’s native strengths, offering performance and type safety advantages.
    - **Tab Functionality**:
        - For all tabs in the app, we utilized the delegate and pop pattern to add functionality. This pattern helps manage interactions between view controllers and handle navigation events. By using delegates, we can ensure that specific actions and updates are communicated between view controllers effectively, leading to a more modular and maintainable codebase. The pop pattern allows for efficient navigation and presentation of new views, enhancing user experience across different tabs.
        - **MainTabController**:
            - We added MainTabController to manage the tabs in the navigation bar. This controller handles the setup and management of the tab bar items, ensuring a smooth transition and consistent navigation between different sections of the app.
- **camelCase Naming Convention**
    - We use the camelCase naming convention because it is the standard practice for developing iOS apps. CamelCase enhances code readability and consistency by capitalizing the first letter of each subsequent word while keeping the first word in lowercase (e.g., userName, profilePicture). This convention helps in distinguishing variables and method names from class names and constants, which often use different naming styles (e.g., PascalCase for class names). By adhering to this convention, our code aligns with common Swift coding practices, making it easier for other developers to understand and collaborate on the codebase.
- **Deep Links**
    - We utilized local deep links instead of global ones because we don’t have a platform or website yet. Initially, we faced challenges with implementing deep links in the AppDelegate but discovered that AppDelegate is primarily used for earlier versions of iOS. For newer versions, handling deep links through the SceneDelegate is recommended. After addressing this, we implemented deep linking by adding the tweet ID to the links. Specifically, we retrieved the tweet ID from the tweet cell where the share button was pressed. We then used our tweet fetch API to fetch the tweet details and displayed the tweet in the appropriate view controller, ensuring a seamless user experience.

---

## Features Breakdown

### **1. Authentication**

- **Login**
    - We implemented login functionality using Firebase’s Auth API with the signInWithEmailAndPassword method. This method allows users to authenticate by providing their email and password. It simplifies the authentication process and integrates seamlessly with Firebase’s user management and security features.
- **Signup**
    - Registering new users with Firebase’s Auth API using the createUserWithEmailAndPassword method.
- **Password Recovery**
    - Functionality to reset user passwords through Firebase using the sendPasswordResetEmail method.
- **User Session Management**
    - Checking if the user is authenticated.
        - We used the main thread for checking user authentication status because it is the highest priority to ensure that the user’s authentication state is determined as soon as possible for a smooth user experience.
    - Showing the user profile if authenticated.
    - Allowing profile edits if authenticated.
- **Logout**
    - Secure logout functionality using Firebase’s signOut method.

### 2. **Main Functionalities**

- **Feed**:
    - Post a tweet.
        - We created a model, view model, and view for managing tweets. For posting a tweet, we wrote API calls using Firebase Realtime Database to test and perform post requests. We structured the database references to add user data efficiently. Our API functions and calls are organized in separate files, utilizing a Singleton pattern in a class named TweetService. This ensures that there is only one instance of TweetService, preventing duplicates and centralizing tweet-related operations.
    - Retweet, Reply, Like, and Share functionalities.
        - We followed a similar approach for handling replies as we did for posting tweets. However, the database reference and data handling methods were different. We also implemented our own data fetching logic specifically for replies, which allows us to manage and display replies efficiently.
        - For handling likes, we created a separate reference in the database named user-likes for each user. We used Firebase’s auto-generated IDs to ensure each like object is unique. This approach helps in efficiently tracking and managing likes for individual tweets.
        - Similarly, for retweets, we set up a distinct reference named user-retweets in the database for each user, also utilizing Firebase’s auto-generated IDs. This ensures unique retweet records and allows us to track retweets accurately.
- **Explore**:
    - Search for users.
        - We listed user cell views using UITableViewController. This approach is suitable for displaying a list of items in a single column, where each cell represents a user. UITableViewController is effective for handling dynamic content, providing built-in support for cell reuse, and managing large datasets efficiently.
    - List users (lowercased strings for case-insensitive search).
    - Open user profiles upon tapping on the user.
        - Tapping on a user cell opens the user profile. We achieve this by using UserService, which contains our API calls and logic for fetching user data. We retrieve the user profile data using the username, then display the user profile by listing user cell views based on the fetched data.
- **Notifications**:
    - **Fetch User Notifications**
        - We fetched user notifications using NotificationService. This service handles API calls to retrieve notifications and manages their display. We sorted notifications by timestamp to ensure that the most recent notifications are displayed at the top.
    - **Display Notifications**
        - Notifications are presented in a UITableView, ordered by their timestamp to provide users with a chronological view of their recent activity.
- **News**:
    - **API Selection**
        - We researched various news APIs and chose one with a generous free tier that offers more API calls. This choice helps us stay within budget while accessing sufficient data.
    - **News View Cell**
        - We aimed to display data such as the news title, description, image, and a link to the news article. However, we encountered an issue where some news references were missing these details. To address this, we switched our news source to Fox News, which provides complete data for all articles.
    - **NewsService**
        - We created NewsService to handle API calls and fetch news data. After retrieving the news objects, we created a News object for each article and displayed them using UITableView.

### 3. **User Profile**

- **View User Profile**
    - To display the user’s profile, we fetch the user data using Firebase’s currentUser.uid method. This allows us to retrieve the current authenticated user’s unique ID and use it to query the database for their specific profile information, including details such as username, first name, family name, and bio.
- **Edit User Profile**
    - For editing the user profile, we utilized the PUT method in the UserService to update user information in the Firebase database reference. This allows users to change their username, update their first name and family name, and modify other profile details like their bio and profile picture. The UserService ensures that updates are made in real-time while keeping the database structure organized.
- **Profile Update Validations**: Ensure valid inputs (e.g., unique username, correct name format).
