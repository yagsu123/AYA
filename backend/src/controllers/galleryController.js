// src/controllers/galleryController.js — photo albums + photos.
// Any authenticated member may create albums and upload photos. An album/photo
// may be deleted by its creator/uploader or by an admin.
const sharp = require('sharp');
const galleryModel = require('../models/galleryModel');
const auditModel = require('../models/auditModel');
const { storeImage } = require('../utils/storage');
const { isAdmin } = require('../middleware/vibhagAccess');

async function listAlbums(req, res, next) {
  try {
    return res.json({ items: await galleryModel.listAlbums() });
  } catch (err) {
    return next(err);
  }
}

async function createAlbum(req, res, next) {
  try {
    const album = await galleryModel.createAlbum({
      title: req.body.title,
      description: req.body.description,
      eventId: req.body.event_id ? parseInt(req.body.event_id, 10) : null,
      year: req.body.year ? parseInt(req.body.year, 10) : null,
      createdBy: req.member.id,
    });
    await auditModel.log({
      actorId: req.member.id,
      action: 'CREATE_ALBUM',
      targetId: album.id,
      targetType: 'album',
    });
    return res.status(201).json({ album });
  } catch (err) {
    return next(err);
  }
}

async function getAlbum(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const album = await galleryModel.findAlbumById(id);
    if (!album) {
      return res.status(404).json({ code: 'ALBUM_NOT_FOUND', message: 'Album not found.' });
    }
    const photos = await galleryModel.listPhotos(id);
    const canManage = isAdmin(req.member) || album.created_by === req.member.id;
    return res.json({ album, photos, can_manage: canManage, is_admin: isAdmin(req.member) });
  } catch (err) {
    return next(err);
  }
}

async function deleteAlbum(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const album = await galleryModel.findAlbumById(id);
    if (!album) {
      return res.status(404).json({ code: 'ALBUM_NOT_FOUND', message: 'Album not found.' });
    }
    if (!isAdmin(req.member) && album.created_by !== req.member.id) {
      return res.status(403).json({
        code: 'FORBIDDEN',
        message: 'Only the album creator or an admin can delete it.',
      });
    }
    await galleryModel.removeAlbum(id);
    await auditModel.log({
      actorId: req.member.id, action: 'DELETE_ALBUM', targetId: id, targetType: 'album',
    });
    return res.json({ id, deleted: true });
  } catch (err) {
    return next(err);
  }
}

async function uploadPhoto(req, res, next) {
  try {
    const albumId = parseInt(req.params.id, 10);
    const album = await galleryModel.findAlbumById(albumId);
    if (!album) {
      return res.status(404).json({ code: 'ALBUM_NOT_FOUND', message: 'Album not found.' });
    }
    if (!req.file) {
      return res.status(400).json({ code: 'VALIDATION_ERROR', message: 'A photo is required.' });
    }

    const processed = await sharp(req.file.buffer)
      .rotate()
      .resize(1600, 1600, { fit: 'inside', withoutEnlargement: true })
      .webp({ quality: 80 })
      .toBuffer();
    const { url } = await storeImage(processed, 'gallery');

    const photo = await galleryModel.addPhoto({
      albumId,
      imageUrl: url,
      caption: req.body.caption,
      uploadedBy: req.member.id,
    });

    await auditModel.log({
      actorId: req.member.id,
      action: 'ADD_PHOTO',
      targetId: albumId,
      targetType: 'album',
      metadata: { photo_id: photo.id },
    });

    return res.status(201).json({ photo });
  } catch (err) {
    return next(err);
  }
}

async function deletePhoto(req, res, next) {
  try {
    const photoId = parseInt(req.params.photoId, 10);
    const photo = await galleryModel.findPhotoById(photoId);
    if (!photo) {
      return res.status(404).json({ code: 'PHOTO_NOT_FOUND', message: 'Photo not found.' });
    }
    if (!isAdmin(req.member) && photo.uploaded_by !== req.member.id) {
      return res.status(403).json({
        code: 'FORBIDDEN',
        message: 'Only the uploader or an admin can delete this photo.',
      });
    }
    await galleryModel.removePhoto(photoId);
    await auditModel.log({
      actorId: req.member.id, action: 'DELETE_PHOTO', targetId: photoId, targetType: 'photo',
    });
    return res.json({ id: photoId, deleted: true });
  } catch (err) {
    return next(err);
  }
}

module.exports = {
  listAlbums,
  createAlbum,
  getAlbum,
  deleteAlbum,
  uploadPhoto,
  deletePhoto,
};
