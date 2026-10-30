# Card Quiz

Flutter 기반 플래시카드 단어장 학습 웹 앱. 라인편집기(Line Editor)의 추가, 삭제, 수정, 출력, 저장, 불러오기 개념을 단어장 앱에 응용한 CRUD 중심 실습 프로젝트. 카드 학습, 오답 복습, 테마 설정은 부가 기능으로 구현.

![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Provider](https://img.shields.io/badge/Provider-6DB33F?style=for-the-badge&logo=flutter&logoColor=white)
![SharedPreferences](https://img.shields.io/badge/SharedPreferences-FF6F00?style=for-the-badge&logo=android&logoColor=white)

## 기술 스택

| 구분 | 기술 | 용도 |
|---|---|---|
| 언어 | Dart | 전체 코드 |
| 프레임워크 | Flutter (Material 3) | 화면 구성, 드래그 순서 변경, 입력 다이얼로그 |
| 표준 라이브러리 | dart:convert | JSON 변환 |
| 외부 라이브러리 | provider, shared_preferences, cupertino_icons | 상태 관리, 로컬 저장, 아이콘 |

## 구현 역량

관련 이론은 [파이썬 기초 역량 정리](https://github.com/Jenny5789/python/tree/main/study_archive) 참조.

| 역량 | 구현 내용 | 코드 | 이론 |
|---|---|---|---|
| 데이터 CRUD | 단어장, 카드의 추가, 수정, 삭제, 드래그 순서 변경, 검색<br>앞면 빈 값 저장 방지 | [핵심 코드](#핵심-코드) | [줄 편집기 insert, delete, replace](https://github.com/Jenny5789/python/blob/main/study_archive/data_structures/02_line_editor.py) |
| 로컬 영속성 | Deck, CardItem을 toJson/fromJson으로 JSON 변환해 SharedPreferences에 저장하고 시작 시 로드<br>최초 실행 시 샘플 단어장 2개 생성 | [deck.dart](lib/models/deck.dart)<br>[storage_service.dart](lib/services/storage_service.dart) | [줄 편집기 save, load](https://github.com/Jenny5789/python/blob/main/study_archive/data_structures/02_line_editor.py)<br>[클래스와 객체지향](https://github.com/Jenny5789/python/blob/main/study_archive/theory/14_classes_oop.md) |
| 상태 관리 | ChangeNotifier를 상속한 AppSettings를 Provider로 주입<br>테마, 글자 크기, 학습 방향을 앱 전체에 즉시 반영 | [app_settings.dart](lib/services/app_settings.dart)<br>[main.dart](lib/main.dart) | [상속](https://github.com/Jenny5789/python/blob/main/study_archive/theory/14_classes_oop.md) |
| 학습 로직 | 카드 뒤집기, 맞춤/틀림 집계<br>학습 방향별 출제(랜덤 shuffle, 뒷면 먼저는 원본을 복사해 앞뒤 교환)<br>틀린 카드만 모은 오답 복습 | [study_screen.dart](lib/screens/study_screen.dart)<br>[result_screen.dart](lib/screens/result_screen.dart) | [흐름 제어](https://github.com/Jenny5789/python/blob/main/study_archive/theory/07_flow_control.md)<br>[얕은 복사와 깊은 복사](https://github.com/Jenny5789/python/blob/main/study_archive/theory/03_data_types.md) |

## 핵심 코드

### 데이터 CRUD

[lib/screens/card_list_screen.dart](lib/screens/card_list_screen.dart)

```dart
// 추가 (라인편집기 insert)
widget.deck.cards.add(CardItem(
  front: frontController.text,
  back: backController.text,
));

// 수정 (라인편집기 replace)
card.front = frontController.text;
card.back = backController.text;

// 삭제 (라인편집기 delete)
widget.deck.cards.remove(card);

// 순서 변경
final card = widget.deck.cards.removeAt(oldIndex);
widget.deck.cards.insert(newIndex, card);

// 모든 변경 뒤 저장 요청
widget.onCardsChanged();
```

- 라인편집기의 insert, replace, delete를 카드 리스트 조작으로 대응
- 앞면이 비어 있으면 추가, 수정을 막고 SnackBar로 안내
- 자식 화면은 onCardsChanged 콜백으로 변경만 알리고, 저장은 HomeScreen의 _onDecksChanged에서 일괄 처리

## 주요 기능

| 기능 | 설명 |
|---|---|
| 단어장, 카드 관리 | 추가, 수정, 삭제, 드래그 순서 변경, 검색 |
| 학습 | 카드를 탭해 뒤집고 맞춤/틀림 체크, 학습 방향(앞면 먼저, 뒷면