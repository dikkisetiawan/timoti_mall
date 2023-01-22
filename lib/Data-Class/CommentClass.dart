class CommentClass {
  String? id;
  String? image_url;
  String? name;
  int? rating;
  String? title;
  String? value;

  CommentClass({
    this.id,
    this.image_url,
    this.name,
    this.rating,
    this.title,
    this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_url': image_url,
      'name': name,
      'rating': rating,
      'title': title,
      'value': value,
    };
  }
}
