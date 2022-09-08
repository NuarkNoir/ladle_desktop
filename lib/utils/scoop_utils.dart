import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import '../models/scoop_app_model.dart';

bool scoopInstalled() {
  final home = Platform.environment["UserProfile"];
  return Directory("$home/scoop").existsSync();
}

Future<List<String>> getScoopBuckets() async {
  final home = Platform.environment["UserProfile"];
  final scoopBucketsDir = Directory("$home/scoop/buckets");
  final buckets = <String>[];

  if (await scoopBucketsDir.exists()) {
    await scoopBucketsDir.list().forEach((element) {
      if (element is Directory) {
        buckets.add(element.path.split("\\").last);
      }
    });
  }

  return buckets;
}

Future<List<ScoopAppModel>> searchScoopApps(String query) async {
  final home = Platform.environment["UserProfile"];
  final buckets = await getScoopBuckets();
  final apps = <ScoopAppModel>[];

  for (final bucket in buckets) {
    final bucketDir = Directory("$home/scoop/buckets/$bucket/bucket");
    final files = bucketDir.listSync().whereType<File>().where(
          (element) =>
              element.path.endsWith(".json") ||
              element.path.endsWith(".yml") ||
              element.path.endsWith(".yaml"),
        );
    for (final file in files) {
      final content = await file.readAsString();
      final data =
          file.path.endsWith(".json") ? jsonDecode(content) : loadYaml(content);

      String appName =
          file.path.split("\\").last.replaceAll(RegExp(r"\.(json|ya?ml)"), "");
      String appDescription = data["description"] ?? "No description";
      DateTime appUpdatedAt = await file.lastModified();

      apps.add(ScoopAppModel(
        name: appName,
        description: appDescription,
        bucket: bucket,
        updatedAt: appUpdatedAt,
      ));
    }
  }

  return apps;
}

Future<List<ScoopAppModel>> getInstalledScoopApps() async {
  final home = Platform.environment["UserProfile"];
  final scoopAppsDir = Directory("$home/scoop/apps");
  final apps = <ScoopAppModel>[];

  if (await scoopAppsDir.exists()) {
    final elementsInDir = scoopAppsDir.listSync().whereType<Directory>();
    for (final element in elementsInDir) {
      String appName = element.path.split("\\").last;
      String appDescription = "No description";
      String appBucket = "UNKNOWN";
      DateTime appUpdatedAt = DateTime.fromMicrosecondsSinceEpoch(0);

      final manifestFile = File("${element.path}/current/manifest.json");
      if (await manifestFile.exists()) {
        final manifestData = jsonDecode(await manifestFile.readAsString());
        appDescription = manifestData["description"] ?? appDescription;
        appUpdatedAt = await manifestFile.lastModified();
      }

      final installFile = File("${element.path}/current/install.json");
      if (await installFile.exists()) {
        final installData = jsonDecode(await installFile.readAsString());
        appBucket = installData["bucket"] ?? appBucket;
      }

      apps.add(ScoopAppModel(
        name: appName,
        description: appDescription,
        bucket: appBucket,
        updatedAt: appUpdatedAt,
      ));
    }
  }

  return apps;
}