import Foundation

struct LectureDetailViewModel {
    // 강의 제목
    let classTitle: String = "호날두의 제과제빵 클래스"

    // 강의 부제목
    let classSubtitle: String = "집에서 간단하게 만드는 제과제빵"

    // 강의 설명
    let description: String = """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nisl tincidunt eget nullam non. Quis hendrerit dolor magna eget est lorem ipsum dolor sit. Volutpat odio facilisis mauris sit amet massa. Commodo odio aenean sed adipiscing diam donec adipiscing tristique. Mi eget mauris pharetra et. Non tellus orci ac auctor augue. Elit at imperdiet dui accumsan sit. Ornare arcu dui vivamus arcu felis. Egestas integer eget aliquet nibh praesent. In hac habitasse platea dictumst quisque sagittis purus. Pulvinar elementum integer enim neque volutpat ac.

    Senectus et netus et malesuada. Nunc pulvinar sapien et ligula ullamcorper malesuada proin. Neque convallis a cras semper auctor. Libero id faucibus nisl tincidunt eget. Leo a diam sollicitudin tempor id. A lacus vestibulum sed arcu non odio euismod lacinia. In tellus integer feugiat scelerisque.
    """

    // 동영상 및 썸네일 이미지 (슬라이드로 표시)
    let videoThumbnails: [String] = [
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4"
    ]
    

    // 강의 중 슬라이드 이미지
    let slideImageNames: [String] = [
        "bread01",
        "bread02",
        "bread03"
    ]

    // 각 이미지에 대한 설명
    let imageDescriptions: [String] = [
        "신선한 재료로 만드는 쿠키 반죽",
        "크랜베리를 올린 데니쉬 페이스트리",
        "갓 구운 부드러운 모닝빵"
    ]
}
