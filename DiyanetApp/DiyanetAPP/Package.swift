// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "DiyanetApp",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "DiyanetApp",
            targets: ["DiyanetApp"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.7.1"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.10.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.15.5"),
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.2.3"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.8.1")
    ],
    targets: [
        .target(
            name: "DiyanetApp",
            dependencies: [
                "Alamofire",
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                "SDWebImage",
                "SDWebImageSwiftUI",
                "Kingfisher"
            ],
            path: "DiyanetApp"
        ),
        .testTarget(
            name: "DiyanetAppTests",
            dependencies: ["DiyanetApp"],
            path: "DiyanetAppTests"
        )
    ]
) 