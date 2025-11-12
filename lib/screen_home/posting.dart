import 'package:flutter/material.dart';

// 1. 게시물 데이터를 담을 Post 클래스를 정의합니다.
class Post {
  final String exercise;
  final String title;
  final String content;
  final String location;

  Post(
      {required this.exercise,
      required this.title,
      required this.content,
      required this.location});
}

class PostingScreen extends StatefulWidget { // StatelessWidget 대신 StatefulWidget을 상속합니다.
  // key를 전달받을 수 있도록 생성자를 수정합니다.
  const PostingScreen({Key? key}) : super(key: key);

  @override
  // 외부에서 접근할 수 있도록 State 클래스를 public으로 변경합니다.
  PostingScreenState createState() => PostingScreenState();
}

class PostingScreenState extends State<PostingScreen> {
  // 게시물 목록을 저장할 리스트
  final List<Post> _posts = [];

  // 새 게시물을 추가하는 함수
  void _addPost(Post post) {
    // 비어있지 않은 내용만 추가
    if (post.title.isNotEmpty || post.content.isNotEmpty) {
      setState(() {
        _posts.insert(0, post); // 새 게시물을 목록의 맨 위에 추가
      });
    }
  }

  // 새 게시물 작성 다이얼로그를 표시하는 함수 (public으로 변경)
  void showNewPostDialog() {
    // 각 입력 필드의 값을 저장할 변수들
    String? selectedExercise;
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final locationController = TextEditingController();

    // 운동 종목 리스트
    final List<String> exercises = ['헬스', '축구', '농구', '야구', '클라이밍', '기타'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // 다이얼로그 내에서 상태를 관리하기 위해 StatefulBuilder 사용
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('새 게시물 작성'),
              content: SingleChildScrollView( // 내용이 길어지면 스크롤 가능하도록
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // 1. 운동 종목 선택
                    DropdownButtonFormField<String>(
                      value: selectedExercise,
                      hint: const Text('운동 종목 선택'),
                      items: exercises.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setDialogState(() {
                          selectedExercise = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    // 2. 게시물 제목
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(hintText: '제목'),
                    ),
                    const SizedBox(height: 8),
                    // 3. 게시글
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(hintText: '내용'),
                      maxLines: 3, // 여러 줄 입력 가능
                    ),
                    const SizedBox(height: 8),
                    // 4. 위치
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(hintText: '위치'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('취소'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('저장'),
                  onPressed: () {
                    // Post 객체를 생성하여 목록에 추가
                    final newPost = Post(
                      exercise: selectedExercise ?? '미지정',
                      title: titleController.text,
                      content: contentController.text,
                      location: locationController.text,
                    );
                    _addPost(newPost); // 새 게시물 추가
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _posts.length, // 게시물 개수만큼 리스트 생성
      itemBuilder: (context, index) {
        final post = _posts[index];
        // 각 게시물을 Card와 ListTile로 보기 좋게 표시
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10), // const 키워드 사용 가능
          child: ListTile(
            leading: CircleAvatar(child: Text(post.exercise.substring(0, 1))),
            title: Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text(post.location),
          ),
        );
      },
    );
  }

}