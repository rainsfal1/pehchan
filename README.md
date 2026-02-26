# Pehchan

Introducing **Pehchan**, an application thoughtfully crafted for blind and visually impaired (VI) parents in Pakistan.

Pehchan aims to assist blind/VI parents in safely and independently administering medication to their children.

## About Pehchan

Administering medication to children poses unique challenges for blind parents, encompassing potential safety risks and emotional stress. Identifying the correct medication, understanding the prescription details, and accurately measuring liquid medication are significant hurdles.

Pehchan empowers parents to independently manage their child's medication safely, reducing the anxiety of giving the wrong or expired medication or exceeding the required dosage. By utilizing semantic labels and integrating seamlessly with screen readers (such as TalkBack), Pehchan provides a highly accessible user interface.

## Core Capabilities

* **Medication Recognition & Information:** Assists users by identifying medication through visual input using the device's camera. Provides essential details such as precautions, registered potential allergic reactions, and expiration dates.
* **Prescription Label Recognition:** Recognizes text labels printed on prescription packets in real-time. Informs the user which part of the day (morning, noon, or evening) the packet is assigned for, and the date of prescription.
* **Manual Prescriptions & DataMatrix Support:** Supports manual entry of prescriptions and scanning of DataMatrix codes commonly used in pharmaceutical packaging.
* **Alarms & Reminders:** Built-in scheduling system to remind parents when it is time to administer a specific medication.
* **Accurate Liquid Medication Intake:** Assists in the process of pouring the desired amount of liquid medication. Users can set the desired dosage using a gesture slider. As the medication is poured, the built-in camera provides varying audio feedback to indicate progress.
* **Remaining Liquid Inventory:** Checks the remaining amount of liquid medication in the bottle to double-check dosages and manage inventory.
* **Customizable Settings:** Register a child's allergies to automatically check for potential risks when scanning medication. Customize interface colors and text sizes for better visibility.

## Offline-First Architecture for Rural Pakistan

Built specifically with the healthcare infrastructure and connectivity challenges of Pakistan in mind, Pehchan is designed to operate completely offline. Recognizing that internet connectivity can be unreliable or unavailable in many rural areas, all data storage and core machine learning models are processed entirely on-device. This guarantees that parents can safely manage their children's medication without depending on an active internet connection.

## Technical Stack

* **Frontend:** Flutter
* **Machine Learning:** TensorFlow Lite, Google ML Kit
* **Database:** SQLite
* **Platform:** Android

Pehchan's mobile layer is built with Flutter, handling the user interface and logical operations with full integration with Android's TalkBack. For on-device Machine Learning, Pehchan utilizes TensorFlow Lite with a YOLO model for bottle and liquid level detection, alongside Google ML Kit for Text Recognition and Barcode Detection. All local data is managed efficiently using SQLite.

## Project Structure

```
lib/
├── main.dart
├── index.dart
└── src/
    ├── app/               # Application lifecycle and background services
    ├── core/              # Core utilities and models
    ├── data/              # Local database (SQLite) and preferences
    ├── nav/               # Navigation and routing logic
    ├── network/           # Connectivity and offline management
    ├── ui/                # User interface pages, widgets, and styles
    └── utils/             # Helper functions and parsers
```

## Acknowledgements

Pehchan is built on top of the original open-source project **PillKaBoo**. We have extended their foundational work to cater specifically to the needs of Pakistan, introducing an offline-first architecture, manual prescription functionalities, allergy detection with proper natural langauge detection,expiry date detection, DataMatrix support, and an complete thorough alarm and reminder system.
