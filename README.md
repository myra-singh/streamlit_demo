# streamlit_project
This repository details the streamlit demo project for Parallel Works which contains a simple hello world demo with streamlit as well as a more involved demo demonstrating some of streamlit's features as well as how to run the demos as a workflow on the Parallel Works platform.

**streamlit_demo**
This is a simple hello world example used to show how to import the streamlit library, create a webpage, and run it on the PW platform. 

**streamlit_example**
This is a more complex demo which takes a data set and shows how to use different tools in the streamlit library to analyze and present the data. 

**Running the demos**
Both demos follow the same structure to run. 
To view a diagram of the file structure, please visit this link: https://docs.google.com/drawings/d/1xIi9AEltsxCV6zuZPxuHyZ6Vg3MRbbthuuVhIlq-uGU/edit?usp=sharing

These files makeup a running workflow on the Parallel Works platform. By running the workflow.xml file, the main.sh file is run which downloads streamlit onto the environment, runs the relevant python file, and creates an html file that contains the streamlit webpage. Since streamlit runs continuously, the workflow will not terminate on its own and rather has to be manually stopped by the user. 

To run the workflow on the platform, create a new "bash" type workflow on the platform. Then, in the PW IDE terminal:

```
# Navigate to the workflow directory created by the platform.
cd /pw/workflows/*name of workflow*

# Remove the default files in this directory.
rm -f

# Manually copy the workflow files into the workflow directory.
git clone https://github.com/parallelworks/streamlit_prpject/*selected_folder* .
(selected folder can be either streamlit_demo or streamlit_example)
```
