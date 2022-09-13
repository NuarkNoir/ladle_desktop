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

Future<Map<String, List<ScoopAppModel>>> searchInstallableApps(
    String query) async {
  final home = Platform.environment["UserProfile"];
  final buckets = await getScoopBuckets();

  Map<String, List<ScoopAppModel>> bucketMap = {};

  for (final bucket in buckets) {
    final apps = <ScoopAppModel>[];
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
      String appHomepage = data["homepage"] ?? "";
      String appVersion = data["version"] ?? "0.0.0";
      DateTime appUpdatedAt = await file.lastModified();

      if (appName.toLowerCase().contains(query.toLowerCase()) ||
          appDescription.toLowerCase().contains(query.toLowerCase())) {
        apps.add(ScoopAppModel(
          name: appName,
          description: appDescription,
          bucket: bucket,
          homepage: appHomepage,
          version: appVersion,
          updatedAt: appUpdatedAt,
        ));
      }
    }
    bucketMap[bucket] = apps;
  }

  return bucketMap;
}

Future<Map<String, List<ScoopAppModel>>> getAllInstallableApps() async {
  final home = Platform.environment["UserProfile"];
  final buckets = await getScoopBuckets();

  Map<String, List<ScoopAppModel>> bucketMap = {};

  for (final bucket in buckets) {
    final apps = <ScoopAppModel>[];
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
      String appHomepage = data["homepage"] ?? "";
      String appVersion = data["version"] ?? "0.0.0";
      DateTime appUpdatedAt = await file.lastModified();

      apps.add(ScoopAppModel(
        name: appName,
        description: appDescription,
        bucket: bucket,
        homepage: appHomepage,
        version: appVersion,
        updatedAt: appUpdatedAt,
      ));
    }
    bucketMap[bucket] = apps;
  }

  return bucketMap;
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
      String appHomepage = "";
      String appVersion = "0.0.0";
      DateTime appUpdatedAt = DateTime.fromMicrosecondsSinceEpoch(0);

      final manifestFile = File("${element.path}/current/manifest.json");
      if (await manifestFile.exists()) {
        final manifestData = jsonDecode(await manifestFile.readAsString());
        appDescription = manifestData["description"] ?? appDescription;
        appHomepage = manifestData["homepage"] ?? appHomepage;
        appVersion = manifestData["version"] ?? appVersion;
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
        homepage: appHomepage,
        version: appVersion,
        updatedAt: appUpdatedAt,
      ));
    }
  }

  return apps;
}

Future<bool> checkAppInstalled(ScoopAppModel app) async {
  final home = Platform.environment["UserProfile"];
  final scoopAppsDir = Directory("$home/scoop/apps");
  final appDir = Directory("${scoopAppsDir.path}/${app.name}");

  return await appDir.exists();
}
