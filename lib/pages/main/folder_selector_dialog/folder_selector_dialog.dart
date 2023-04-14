import 'dart:io';

import 'package:flutter/material.dart';
import 'package:youtube_downloader/shared/styles.dart';
import 'package:youtube_downloader/shared/widgets/ClickableColumn.dart';

class FolderSelectorDialog extends StatefulWidget {
  const FolderSelectorDialog({Key? key}) : super(key: key);

  @override
  State<FolderSelectorDialog> createState() => _FolderSelectorDialogState();
}

class _FolderSelectorDialogState extends State<FolderSelectorDialog> {
  Directory currentDir = Directory('/storage/emulated/0');

  @override
  Widget build(BuildContext context) {
    var subDirs = currentDir.listSync().whereType<Directory>().toList();
    return Dialog(
        insetPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Container(
          padding:
              const EdgeInsets.only(left: 14, right: 14, top: 14, bottom: 4),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              "Navigate to the folder you want: ",
              style: Styles.labelTextStyle
                  .copyWith(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    (currentDir.path == '/storage/emulated/0')
                        ? const SizedBox()
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 12),
                              Expanded(
                                child: ClickableColumn(
                                  children: [
                                    SizedBox(height: 8),
                                    Text('../',
                                        maxLines: 1,
                                        style: Styles.labelTextStyle),
                                    SizedBox(height: 8),
                                    Divider(
                                      indent: 3,
                                      thickness: 0,
                                      height: 6,
                                      color: Colors.black12,
                                    )
                                  ],
                                  splashColor: Colors.greenAccent.shade100,
                                  onClick: () {
                                    setState(() {
                                      currentDir = currentDir.parent;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                    ...List.generate(
                      subDirs.length,
                      (index) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 12),
                            Expanded(
                              child: ClickableColumn(
                                children: [
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.folder,
                                        color: Colors.black.withAlpha(110),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                          subDirs[index].path.substring(
                                              subDirs[index]
                                                      .path
                                                      .lastIndexOf('/') +
                                                  1),
                                          maxLines: 1,
                                          style: Styles.labelTextStyle),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(
                                    indent: 3,
                                    thickness: 0,
                                    height: 6,
                                    color: Colors.black12,
                                  )
                                ],
                                splashColor: Colors.greenAccent.shade100,
                                onClick: () {
                                  setState(() {
                                    currentDir = subDirs[index];
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, currentDir.path);
                  },
                  child: const Text(
                    'Cancel',
                    style: Styles.labelTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, currentDir.path);
                  },
                  child: const Text(
                    'Select Here',
                    style: Styles.labelTextStyle,
                  ),
                )
              ],
            ),
          ]),
        ));
  }
}
