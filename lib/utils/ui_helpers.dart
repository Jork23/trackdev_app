import 'package:flutter/material.dart';
import '../project/project_details_page.dart';
import '../../utils/translations.dart';

class UIHelpers {

  static InputDecoration customInputDecorationTextField({
    required Color inputFillColor,
    required Color borderColor,
    required Color hintColor,
    String? hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: inputFillColor,
      hintText: hintText,
      hintStyle: TextStyle(color: hintColor),
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2D5AF0), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
    );
  }

  static InputDecorationTheme customInputDecorationDropdownMenu({
    required Color inputFillColor,
    required Color borderColor,
    required Color hintColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: inputFillColor,
      hintStyle: TextStyle(color: hintColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2D5AF0), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
    );
  }

  static MenuStyle customMenuStyle({
    required Color cardColor,
    required Color borderColor,
  }) {
    return MenuStyle(
      backgroundColor: WidgetStateProperty.all(cardColor),
      surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
      side: WidgetStateProperty.all(
        BorderSide(color: borderColor, width: 1),
      ),
    );
  }

  static Widget costumAppBar({
    required Color dividerColor,
    required Color textColor,
    required Color subtitleColor,
    required String title,
    String? subtitile
  }) {
    return Column(
      children:[
        Divider(color: dividerColor, thickness: 1),
        Text (
          title,
          style: TextStyle(
            color: textColor, 
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        if(subtitile!=null)
          Text(
            subtitile,
            style: TextStyle(
              fontSize: 13,
              color: subtitleColor
            ),
          ),
        Divider(color: dividerColor, thickness: 1),
      ],
    );
  }

  static Widget costumBackPopAppBar({ required BuildContext context, String? text, required Color textColor}){
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D5AF0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Row(
            children: [
              Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
              if(text!=null)
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
            ]
          ),
        ),
        const SizedBox(width: 15),
        const Icon(
          Icons.layers_outlined, 
          color: Color(0xFF2D5AF0),
          size: 28,
        ),
        const SizedBox(width: 8),
        Text(
          'TrackDev',
          style: TextStyle(
            color: textColor, 
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  static Widget costumTitle(String text,Color textColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static Widget costumSubtitle(String text, Color subtitleColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: subtitleColor,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  static Widget costumMessage(bool isSuccess,String message){
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess ? Colors.green.shade200 : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline, 
            color: isSuccess ? Colors.green : Colors.red, 
            size: 20
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isSuccess ? Colors.green : Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget costumErrorMessage(String errorMessage){
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.red.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget costumRequirement(String text,bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  static Widget costumPassword({
    required Color inputFillColor,
    required Color borderColor,
    required Color hintColor,
    required Color textColor,
    required Color iconColor,
    required String text, 
    required TextEditingController controller
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UIHelpers.costumTitle(text, textColor),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: true,
          style: TextStyle(color: textColor),
          decoration: UIHelpers.customInputDecorationTextField(
            inputFillColor: inputFillColor,
            borderColor: borderColor,
            hintColor: hintColor,
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock_outline, color: iconColor),
          ),
        ),
      ]
    );
  }

  static Color getIconColor(String type) {
    switch (type) {
      case "CLOSED":
        return const Color(0xFF5F6368);
      case "DRAFT":
        return const Color(0xFF1E8E3E);
      case "ACTIVE":
        return const Color(0xFFF29900);
      default:
        return const Color(0xFF5F6368);
    }
  }

  static Color getIconBackgroundColor(String type) {
    switch (type) {
      case "CLOSED":
        return const Color(0xFFF1F3F4);
      case "DRAFT":
        return const Color(0xFFE6F4EA);
      case "ACTIVE":
        return const Color(0xFFFEF7E0);
      default:
        return const Color(0xFFF1F3F4);
    }
  }

  static Color getTaskColor(String type) {
    switch (type) {
      case "BUG":
        return const Color(0xFFFCA5A5);
      case "TASK":
        return const Color(0xFF93C5FD);
      case "USER_STORY":
        return const Color(0xFFD8B4FE);
      default:
        return const Color(0xFF5F6368);
    }
  }

  static Color getTaskBackgroundColor(String type) {
    switch (type) {
      case "BUG":
        return const Color(0xFF7F1D1D);
      case "TASK":
        return const Color(0xFF1E3A8A);
      case "USER_STORY":
        return const Color(0xFF581C87);
      default:
        return const Color(0xFFF1F3F4);
    }
  }

  static String translateType(String type, String currentLang) {
    switch (type) {
      case "BUG":
        return Translations.get('tasks.typeBug', currentLang);
      case "TASK":
        return Translations.get('tasks.typeTask', currentLang);
      case "USER_STORY":
        return Translations.get('tasks.typeUserStory', currentLang);
      default:
        return type;
    }
  }

  static String translateStatus(String status, String currentLang) {
    switch (status) {
      case "BACKLOG":
        return Translations.get('tasks.statusBacklog', currentLang);
      case "TODO":
        return Translations.get('tasks.statusTodo', currentLang);
      case "INPROGRESS":
        return Translations.get('tasks.statusInProgress', currentLang);
      case "VERIFY":
        return Translations.get('tasks.statusVerify', currentLang);
      case "DONE":
        return Translations.get('tasks.statusDone', currentLang);
      default:
        return status;
    }
  }

  static String formatDate(String isoDate) {
    final dt = DateTime.parse(isoDate);
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  static Color hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.pinkAccent.shade100;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Widget costumProject({
    required BuildContext context,
    required Color textColor,
    required Color iconColor,
    required Color subtitleColor,
    required  Map<String, dynamic> project
  }){
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailsPage(project: project),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: costumProjectInfo(textColor: textColor, iconColor: iconColor,subtitleColor: subtitleColor,project: project)
      )
    );
  }

  static Widget costumProjectInfo({
    required Color textColor,
    required Color iconColor,
    required Color subtitleColor,
    required  Map<String, dynamic> project
  }){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255,219,252,231),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color:Color.fromARGB(255,0,166,62)),
          ),
          child: const Icon(
            Icons.folder_open_outlined,
            color: Color.fromARGB(255,0,166,62),
            size: 24
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project['name'] ?? '',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if(project['course']?['startYear'] != null)
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: iconColor,
                      size: 12
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                      "${project['course']?['startYear']} - ${project['course']?['startYear'] + 1}",
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ]
                ),
                Row(
                  children: [                                  
                    Icon(
                      Icons.menu_book,
                      color: iconColor,
                      size: 12
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        project['course']?['subject']?['name'] ?? '',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                )
            ]
          )
        )
      ],
    );
  }

  static Widget costumTask({
    required Color textColor,
    required Color subtitleColor,
    required  Map<String, dynamic> task,
    required String currentLang
  }){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3B82F6)),
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: const Color(0xFF3B82F6), 
              size: 25
            ),
          ),
          const SizedBox(width: 12),
          costumTaskInfo(textColor: textColor, subtitleColor: subtitleColor, task: task, currentLang: currentLang)
        ],
      ),
    );
  }

  static Widget costumTaskInfo({
    required Color textColor,
    required Color subtitleColor,
    required  Map<String, dynamic> task,
    required String currentLang
  }){
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if(task['taskKey'] != null)
                Text(
                  task['taskKey'],
                  style: TextStyle(
                    color: subtitleColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  task['name'] ?? '',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if(task['type'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: getTaskBackgroundColor(task['type']),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: getTaskColor(task['type']), width: 1),
                  ),
                  child: Text(
                    translateType(task['type'],currentLang),
                    style: TextStyle(
                      color: getTaskColor(task['type']),
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if(task['status'] != null)...{
                Text(
                    ' • ',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  translateStatus(task['status'],currentLang),
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 10,
                  ),
                ),
              },
              if(task['estimationPoints'] != null && task['estimationPoints'] != 0)...{
                  Text(
                  ' • ',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E3B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF34D399)),
                  ),
                  child: Text(
                    '${task['estimationPoints']} ${Translations.get('tasks.points', currentLang)}',
                    style: TextStyle(
                      color: const Color(0xFF34D399),
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              },
              if(task['assignee'] != null && task['assignee']?['color'] != null)...{
                Text(
                  ' • ',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: hexToColor(task['assignee']?['color']),
                        child: Text(
                          "${task['assignee']?['capitalLetters']}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          task['assignee']['fullName'] ?? '',
                          style: TextStyle(color: textColor, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              },
            ],
          ),
        ],
      ),
    );
  }

  

  static Widget costumAddIsNotSuccess({
    required BuildContext context,
    required Color textColor,
    required Color borderColor,
    required String currentLang,
  }){
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: borderColor),
        ),
        child: Text(
          Translations.get('common.back', currentLang),
          style: TextStyle(color: textColor)
        ),
      ),
    );
  }

}