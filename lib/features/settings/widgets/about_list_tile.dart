import 'package:flutter/cupertino.dart';
import 'package:retropod/core/extensions/build_context_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutListTile extends StatelessWidget {
  final String titleText;
  final String valueText;
  final String? linkUrl;
  const AboutListTile({
    super.key,
    required this.titleText,
    required this.valueText,
    this.linkUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titleText,
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.appPrimaryTextColor,
            ),
          ),
          GestureDetector(
            onTap: linkUrl == null
                ? null
                : () => launchUrl(
                    Uri.parse(linkUrl!),
                    mode: LaunchMode.externalApplication,
                  ),
            child: Text(
              valueText,
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.appPrimaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
