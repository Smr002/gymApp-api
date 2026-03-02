import { v2 as cloudinary } from 'cloudinary';
import { env } from '@config/env';

cloudinary.config({
  cloud_name: env.CLOUDINARY_CLOUD_NAME,
  api_key:    env.CLOUDINARY_API_KEY,
  api_secret: env.CLOUDINARY_API_SECRET,
});

export { cloudinary };

export const uploadFile = async (
  filePath: string,
  folder: string,
  opts: object = {},
): Promise<{ url: string; publicId: string }> => {
  const r = await cloudinary.uploader.upload(filePath, {
    folder: `gymapp/${folder}`,
    ...opts,
  });
  return { url: r.secure_url, publicId: r.public_id };
};

export const deleteFile = async (publicId: string) =>
  cloudinary.uploader.destroy(publicId);
