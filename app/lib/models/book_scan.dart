class BookScan {
  final int? id; final String code,title,author,grade,category,isbn,publisher,language; final String? coverUrl; final bool matched; final DateTime? scannedAt;
  BookScan({this.id,required this.code,this.title='',this.author='',this.grade='',this.category='',this.isbn='',this.publisher='',this.language='',this.coverUrl,this.matched=false,this.scannedAt});
  factory BookScan.fromJson(Map<String,dynamic> j)=>BookScan(id:j['id'],code:j['code']??'',title:j['title']??'',author:j['author']??'',grade:j['grade']??'',category:j['category']??'',isbn:j['isbn']??'',publisher:j['publisher']??'',language:j['language']??'',coverUrl:j['cover_url'],matched:j['matched_catalog']==true,scannedAt:j['scanned_at']!=null?DateTime.tryParse(j['scanned_at']):null);
}
