class SlideshowImageClass {
  String? id;
  String? image_url;
  String? redirection;

  SlideshowImageClass({
     this.id,
     this.image_url,
     this.redirection,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_url': image_url,
      'redirection': redirection,
    };
  }
}
