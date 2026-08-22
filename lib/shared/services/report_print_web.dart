import 'package:web/web.dart' as web;

bool get canPrintReport => true;
void printReport() => web.window.print();
