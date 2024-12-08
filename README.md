# ePaddy: Sustainable Paddy Production with Technology

## Project Overview

ePaddy is a mobile application designed to address the challenges in traditional paddy cultivation in Sri Lanka. It integrates technology to improve disease and pest management, soil and water management, and farming efficiency, ultimately increasing paddy harvests and enhancing farmers' livelihoods.

## Research Problem

Paddy farming in Sri Lanka suffers from several issues,

   •	Ineffective disease and pest management.

   •	Poor soil and water management practices.

   •	Limited access to information and modern agricultural methods.

These challenges reduce crop yields and negatively impact farmers' incomes.

## Proposed Solutions

The ePaddy application provides innovative solutions to address these challenges:

1. Disease Management

    •	Predict paddy diseases based on weather conditions and send alerts to farmers with information about the predicted disease.

    •	Identify paddy diseases through image analysis and recommend effective treatments.

3. Pest Management

    •	Identify pests and pest infections through image analysis.

    •	Recommend solutions to address pest-related issues.

5. Paddy Growth Management

    •	Use image analysis to identify the growth stages of paddy and inform farmers about necessary actions for each growth stage.

7. Soil Quality Management

    •	Measure and manage soil quality, including NPK (Nitrogen, Phosphorus, Potassium) levels.

    •	Predict suitable rice breeds based on soil conditions.

9. Water Management

    •	Implement IoT-based water management to monitor and maintain optimal water levels for paddy cultivation.

## Goal

ePaddy aims to improve paddy farming in Sri Lanka by combining technology and traditional practices to boost production, reduce resource waste, and provide farmers with relevant information.

## System Overview Diagram

![image](https://github.com/user-attachments/assets/063f7fc2-0b96-4555-8f2c-80a588f02268)

## Architectural Diagram

![Architecture_diagram](https://github.com/user-attachments/assets/a9217bf0-c735-4110-9c0d-ef52ae37b580)

## Dependencies

1. Data dependencies

   •	weather data: Accurate real-time data for temperature, humidity, and rainfall to predict diseases

   •	Image data: High-quality images of paddy crops to train and validate the CNN model for disease, pest, and growth stage identification.

   •	Soil data: Data on soil quality, including NPK levels

3. Technological Dependencies
   
   •	Machine Learning Models:
   
      * CNN for image analysis (disease, pests, growth stages).
   
      * Gradient Boosting models for disease prediction.
   
   •	IoT Sensors: Sensors for monitoring soil quality and water levels.

   •	Mobile Application Framework: Flutter for building the app interface.

   •	Backend Services: API frameworks like Flask, Django, or Node.js to connect the app with the models and database.

   •	Cloud Services: For data storage (images, weather, and predictions) and model deployment.

   •	Notification System: Services like Firebase Cloud Messaging for sending real-time alerts.
   


### Repository Link : https://github.com/KavishkaBingun/Research-Project-ePaddy
