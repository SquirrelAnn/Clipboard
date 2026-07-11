import 'dart:io';

import 'package:clipboard/models/category.dart';
import 'package:clipboard/repositories/categories_repository.dart';
import 'package:path/path.dart' as p;

class BackupService {
  BackupService(this._repository);

  final CategoriesRepository _repository;

  Future<void> exportToDirectory(String directoryPath) async {
    final sourcePath = await _repository.storagePath;
    final jsonSource = File(p.join(sourcePath, 'snippets.json'));
    if (!jsonSource.existsSync()) {
      throw StorageException('Nothing to export yet.');
    }

    final targetDir = Directory(directoryPath);
    if (!targetDir.existsSync()) {
      await targetDir.create(recursive: true);
    }

    await jsonSource.copy(p.join(directoryPath, 'snippets.json'));

    final imagesSource = Directory(p.join(sourcePath, 'images'));
    if (imagesSource.existsSync()) {
      final imagesTarget = Directory(p.join(directoryPath, 'images'));
      if (imagesTarget.existsSync()) {
        await imagesTarget.delete(recursive: true);
      }
      await _copyDirectory(imagesSource, imagesTarget);
    }
  }

  Future<void> importFromDirectory(
    String directoryPath, {
    required bool replaceExisting,
  }) async {
    final importFile = File(p.join(directoryPath, 'snippets.json'));
    if (!importFile.existsSync()) {
      throw StorageException('No snippets.json found in selected folder.');
    }

    final importedCategories = await CategoriesRepository.parseCategoriesFile(importFile);
    final importImagesDirectory = p.join(directoryPath, 'images');

    if (replaceExisting) {
      await _repository.replaceAll(
        importedCategories,
        importImagesDirectory: importImagesDirectory,
      );
      return;
    }

    await _repository.mergeFrom(
      importedCategories,
      importImagesDirectory: importImagesDirectory,
    );
  }

  Future<void> _copyDirectory(Directory source, Directory target) async {
    if (!target.existsSync()) {
      await target.create(recursive: true);
    }

    await for (final entity in source.list(recursive: false)) {
      final targetPath = p.join(target.path, p.basename(entity.path));
      if (entity is File) {
        await entity.copy(targetPath);
      } else if (entity is Directory) {
        await _copyDirectory(entity, Directory(targetPath));
      }
    }
  }
}
