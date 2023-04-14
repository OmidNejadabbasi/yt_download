import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_downloader/dependency_container.dart';
import 'package:youtube_downloader/domain/entities/download_item.dart';
import 'package:youtube_downloader/pages/main/link_extractor_dialog/link_extractor_dialog_bloc.dart';
import 'package:youtube_downloader/pages/main/link_extractor_dialog/link_extractor_dialog_events.dart';
import 'package:youtube_downloader/pages/main/link_extractor_dialog/link_extractor_dialog_states.dart';
import 'package:youtube_downloader/shared/my_flutter_app_icons.dart';
import 'package:youtube_downloader/shared/styles.dart';
import 'package:youtube_downloader/shared/widgets/ClickableColumn.dart';
import 'package:youtube_downloader/shared/widgets/icon_button.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeLinkExtractorDialog extends StatefulWidget {
  const YoutubeLinkExtractorDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<YoutubeLinkExtractorDialog> createState() =>
      _YoutubeLinkExtractorDialogState();
}

class _YoutubeLinkExtractorDialogState
    extends State<YoutubeLinkExtractorDialog> {
  final _linkInputController = TextEditingController();

  late LinkExtractorDialogBloc _bloc;
  int selectedLinkInd = -1;
  DownloadItemEntity? selectedItem;

  @override
  void initState() {
    super.initState();
    _bloc = sl();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Container(
        padding: const EdgeInsets.only(left: 14, right: 14, top: 14, bottom: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Link',
                    style: Styles.labelTextStyle,
                  ),
                  NIconButton(
                    icon: CustomIcons.clipboard,
                    iconSize: 20,
                    onPressed: () async {
                      ClipboardData? cData =
                          await Clipboard.getData("text/plain");
                      var clipText = await showDialog(
                          context: context,
                          builder: (contxt) {
                            var textColor =
                                cData == null ? Colors.black26 : Colors.black54;
                            var isValid = isYoutubeLink(cData!.text!);
                            return Dialog(
                              insetPadding: const EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 24),
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 14, right: 14, top: 14, bottom: 14),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClickableColumn(
                                      onClick: cData != null && isValid
                                          ? () {
                                              Navigator.of(contxt)
                                                  .pop(cData.text);
                                            }
                                          : null,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                                child: Text(
                                              cData == null
                                                  ? "No data"
                                                  : cData.text!,
                                              style: Styles.labelTextStyle
                                                  .copyWith(color: textColor),
                                            )),
                                            Icon(
                                              isValid
                                                  ? Icons.check_circle
                                                  : Icons.error_outline,
                                              color: isValid
                                                  ? Colors.green
                                                  : Colors.redAccent,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }) as String?;

                      if (clipText == null) {
                        _bloc.eventSink.add(NoClipboardDataEvent());
                        return;
                      } else {
                        var link = clipText ?? '';
                        _bloc.eventSink.add(ExtractLinkEvent(link));
                        _linkInputController.text = link;
                      }
                    },
                  ),
                ]),
          ),
          const SizedBox(
            height: 12,
          ),
          TextFormField(
            controller: _linkInputController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Video Link or Id…',
              labelStyle: Styles.labelTextStyle,
            ),
          ),
          StreamBuilder(
            stream: _bloc.dialogState,
            builder: (context, snapshot) {
              debugPrint(snapshot.data.runtimeType.toString());
              if (snapshot.data.runtimeType == LinksLoadedState) {
                var state = snapshot.data as LinksLoadedState;
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(5),
                    child: Column(children: [
                      Row(
                        children: [
                          Container(
                            child: Image.network(
                              state.videoMeta.thumbnails.mediumResUrl,
                              height: 96,
                              width: 128,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/placeholder.jpeg',
                                  height: 96,
                                  width: 128,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(3)),
                                border: Border.all(
                                  color: Colors.grey,
                                )),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    state.videoMeta.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      ...List.generate(state.links.length, (index) {
                        return Row(
                          children: [
                            Radio(
                              value: index,
                              groupValue: selectedLinkInd,
                              onChanged: (val) {
                                if (val == null) return;
                                selectedLinkInd = index;
                                setState(() {
                                  selectedItem = state.links[index];
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Expanded(
                              child: Text(
                                '${state.links[index].format.toUpperCase()} ${state.links[index].quality} ${state.links[index].fps}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      })
                    ]),
                  ),
                );
              } else if (snapshot.data.runtimeType == LoadingUnsuccessful) {
                return Container(
                    padding: const EdgeInsets.only(top: 24, bottom: 8),
                    child: RichText(
                      text: TextSpan(
                          text: "Error: ",
                          style: Styles.labelTextStyle,
                          children: [
                            TextSpan(
                              text: (snapshot.data as LoadingUnsuccessful).e,
                              style: Styles.labelTextStyle
                                  .copyWith(color: Colors.red),
                            )
                          ]),
                    ));
              } else if (snapshot.data.runtimeType == LinksListLoading) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Paste the link from clipboard'),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, null);
                },
                child: Text(
                  'Cancel',
                  style:
                      Styles.labelTextStyle.copyWith(color: Colors.blueAccent),
                ),
              ),
              TextButton(
                onPressed: selectedItem == null
                    ? null
                    : () {
                        Navigator.pop(context, selectedItem);
                      },
                child: Text(
                  'Start',
                  style: (selectedLinkInd != -1)
                      ? Styles.labelTextStyle.copyWith(color: Colors.blueAccent)
                      : Styles.labelTextStyle,
                ),
              )
            ],
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }

  bool isYoutubeLink(String text) {
    return VideoId.parseVideoId(text) != null;
  }
}
