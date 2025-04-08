# DEMO_AIKIT_IMAGETAG

Description (4D 20 R9)

Find more information on the [blog post](https://blog.4d.com/unlock-the-power-of-ai-with-4d-aikit-automate-create-and-innovate).

## Installing and Using a 4D Project

### Pre-requisites

* **OpenAI API Key**: This demo requires an OpenAI API key.  
  - You can generate one by creating an account at: [https://platform.openai.com/account/api-keys](https://platform.openai.com/account/api-keys)  
  - **Best practices for API key usage**:
    - Never share your key publicly (e.g., in GitHub repositories).
    - Store the key securely (use environment variables or a config file not under version control).
    - Monitor your usage on the OpenAI dashboard to avoid unexpected charges.
    - Consider setting usage limits or alerts on your OpenAI account.

* Download the latest **Release** version of 4D from: https://us.4d.com/product-download  
  Or the latest **Beta** version from: https://discuss.4d.com  
* Follow the activation steps for 4D here: https://developer.4d.com/docs/GettingStarted/installation  

### Steps to Run the Project

* Clone or download the GitHub repository containing the 4D project to your local machine. Need help? Check out [this blog post](https://blog.4d.com/github-4d-depot/).
* Open the 4D project in 4D by navigating to **File > Open Project**. More details here: [Open a project](https://developer.4d.com/docs/GettingStarted/creating#opening-a-project)
* Add your OpenAI API key in the `Datastore` class, in the following line:  
  ```4d
  var $client := cs.AIKit.OpenAI.new("YourApiKey")
  ```
  Replace `"YourApiKey"` with your actual API key.
* Play with this HDI.
* Navigate to the **Mode > Return to Design Mode** menu to view the code.

By following these steps, you will be able to successfully install and run the 4D project.