import ProjectDescription

let prefixBundleID: String = "ThreeIdiots"

let project = Project(
    name: "SlowStarter",
    settings: .settings(
        base: [
            "CODE_SIGN_IDENTITY": "Apple Development",
            "DEVELOPMENT_TEAM": "59FP2PXRXK"
        ],
        configurations: [
            .debug(name: "Debug", xcconfig: .relativeToRoot("SlowStarter/Sources/Config/API/Secrets.xcconfig")),
            .release(name: "Release", xcconfig: .relativeToRoot("SlowStarter/Sources/Config/API/Secrets.xcconfig"))
        ]
    ),
    targets: [
        .target(
            name: "SlowStarter",
            destinations: .iOS,
            product: .app,
            bundleId: "\(prefixBundleID).SlowStarter",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": true,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                                ]
                            ]
                        ]
                    ],
                    "GEMINI_API_KEY": "$(GEMINI_API_KEY)"
                ]
            ),
            sources: ["SlowStarter/Sources/**"],
            resources: [
                "SlowStarter/Resources/**",
                "SlowStarter/Sources/Data/Persistence/CoreDataModel.xcdatamodeld"
            ],
            scripts: [
                .pre(
                    script: """
                  # SwiftLint가 설치되어 있고 PATH에 잡히는지 확인
                  if SWIFTLINT_PATH=$(which swiftlint); then
                    echo "SwiftLint found at: $SWIFTLINT_PATH"
                    # which swiftlint로 찾은 경로를 사용하여 실행
                    "$SWIFTLINT_PATH" # 따옴표로 감싸서 경로에 공백이 있어도 안전하게 처리
                  else
                    echo "warning: SwiftLint not installed or not in PATH. Install or check PATH."
                    echo "Attempting to locate SwiftLint in common Homebrew paths..."
                  
                    # Apple Silicon Homebrew 경로 시도
                    if [ -f "/opt/homebrew/bin/swiftlint" ]; then
                      echo "SwiftLint found at /opt/homebrew/bin/swiftlint"
                      /opt/homebrew/bin/swiftlint
                    # Intel Homebrew 경로 시도
                    elif [ -f "/usr/local/bin/swiftlint" ]; then
                      echo "SwiftLint found at /usr/local/bin/swiftlint"
                      /usr/local/bin/swiftlint
                    else
                      echo "warning: SwiftLint still not found. Download from https://github.com/realm/SwiftLint"
                      # exit 1 # 필요하다면 린트 실패 시 빌드도 실패하도록 설정
                    fi
                  fi
                  """,
                    name: "SwiftLint",
                    basedOnDependencyAnalysis: false
                )
            ],
            dependencies: []
        ),
        .target(
            name: "SlowStarterTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(prefixBundleID).SlowStarterTests",
            infoPlist: .default,
            sources: ["SlowStarter/Tests/**"],
            resources: [],
            dependencies: [.target(name: "SlowStarter")]
        )
    ]
)
