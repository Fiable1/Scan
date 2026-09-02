import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_shell.dart';

const primaryBlue=Color(0xFF0D47A1);
void main()=>runApp(const BookScannerApp());
class BookScannerApp extends StatelessWidget { const BookScannerApp({super.key}); @override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Rwanda School Book Scanner',theme:ThemeData(colorScheme:ColorScheme.fromSeed(seedColor:primaryBlue),useMaterial3:true,fontFamily:'Arial'),home:FutureBuilder(future:ApiService.token(),builder:(c,s)=>s.connectionState!=ConnectionState.done?const Scaffold(body:Center(child:CircularProgressIndicator())):(s.data!=null?const HomeShell():const LoginScreen()))); }
