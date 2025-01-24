class ApiResponseModel {
  final int status;
  final String message;
  final Data data;

  ApiResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });


  factory ApiResponseModel.fromJson(Map<String, dynamic> json) => ApiResponseModel(
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  final List<Post> posts;

  Data({
    required this.posts,
  });


  factory Data.fromJson(Map<String, dynamic> json) => Data(
    posts: List<Post>.from(json["posts"].map((x) => Post.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "posts": List<dynamic>.from(posts.map((x) => x.toJson())),
  };
}

class Post {
  final String title;
  final String slug;
  final String html;
  final String commentId;
  final String featureImage;
  final String url;
  final String excerpt;

  Post({
    required this.title,
    required this.slug,
    required this.html,
    required this.commentId,
    required this.featureImage,
    required this.url,
    required this.excerpt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    title: json["title"],
    slug: json["slug"],
    html: json["html"],
    commentId: json["comment_id"],
    featureImage: json["feature_image"],
    url: json["url"],
    excerpt: json["excerpt"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "slug": slug,
    "html": html,
    "comment_id": commentId,
    "feature_image": featureImage,
    "url": url,
    "excerpt": excerpt,
  };
}
