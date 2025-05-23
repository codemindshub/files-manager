-- =====================================================================================
-- FILE MANAGEMENT SYSTEM - DATABASE SCHEMA DOCUMENTATION
-- =====================================================================================
--
-- PURPOSE: This schema supports a hierarchical file management system with the following features:
-- • User-owned files and folders with unlimited nesting depth
-- • Soft delete functionality for data recovery
-- • Public/private file sharing capabilities
-- • Automatic thumbnail generation for images
-- • File integrity and metadata tracking
--
-- TECHNOLOGY STACK:
-- • ORM: Hibernate/JPA (auto-generates schema from entity annotations)
-- • Database: PostgreSQL (recommended) or MySQL
-- • File Storage: Local filesystem or cloud storage (S3, etc.)
--
-- IMPORTANT NOTES:
-- • This SQL is for DOCUMENTATION PURPOSES ONLY
-- • Hibernate will automatically create tables, indexes, and constraints from @Entity annotations
-- • Actual column types and constraints may vary based on Hibernate configuration
-- • DO NOT run this script in production - use Hibernate's ddl-auto instead
--
-- SCHEMA VERSION: 1.0
-- LAST UPDATED: 2025-05-23
-- =====================================================================================

-- =====================================================================================
-- ENUMS - Custom Data Types
-- =====================================================================================


-- File type enumeration to distinguish between files and folders
CREATE TYPE "FileType" AS ENUM (
  'folder',  -- Directory/container for other files
  'file'     -- Actual file with content
);

-- Thumbnail size variants for optimized image delivery
CREATE TYPE "SizeType" AS ENUM (
  'small',   -- Typically 100x100px for lists/previews
  'medium',  -- Typically 300x300px for cards/galleries
  'large'    -- Typically 800x800px for detailed views
);


-- =====================================================================================
-- CORE TABLES
-- =====================================================================================

-- -----------------------------------------------------------------------------
-- Users Table: System users who can own and manage files
-- -----------------------------------------------------------------------------
CREATE TABLE "user" (
    "id" uuid UNIQUE PRIMARY KEY NOT NULL,
    "email" varchar(255) UNIQUE NOT NULL,           -- User login identifier
    "password" varchar(255) NOT NULL,               -- Hashed password (bcrypt recommended)
    "is_active" boolean DEFAULT true,               -- Account status (soft disable)
    "created_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- Files Table: Hierarchical file and folder storage
-- -----------------------------------------------------------------------------
-- DESIGN NOTES:
-- • Single table for both files and folders (discriminated by 'type' field)
-- • Self-referencing parent_id creates unlimited folder nesting
-- • Soft delete preserves data and folder structure
-- • File-specific fields (mime_type, size, storage_path) are null for folders
-- -----------------------------------------------------------------------------
CREATE TABLE "file" (
    "id" uuid UNIQUE PRIMARY KEY NOT NULL,
    "name" varchar(255) NOT NULL,                   -- Display name (with extension for files)
    "type" FileType NOT NULL,                       -- 'file' or 'folder'

    -- File-specific metadata (NULL for folders)
    "mime_type" varchar(100),                       -- MIME type (e.g., 'image/jpeg', 'text/plain')
    "size" bigint,                                  -- File size in bytes
    "file_extension" varchar(10),                   -- Extension extracted from filename (.pdf, .jpg, etc.)
    "storage_path" varchar(512),                    -- Physical storage location or cloud path

    -- Access and sharing controls
    "is_public" boolean DEFAULT false,              -- Public access flag
    "is_deleted" boolean DEFAULT false,             -- Soft delete flag
    "last_accessed_at" timestamp,                   -- Last download/view timestamp

    -- Audit timestamps
    "created_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" timestamp,                         -- Soft delete timestamp

    -- Relationships
    "owner_id" uuid NOT NULL,                       -- References user.id
    "parent_id" uuid                                -- Self-reference for folder hierarchy (NULL = root level)
);

-- -----------------------------------------------------------------------------
-- File Thumbnails: Generated image previews for visual files
-- -----------------------------------------------------------------------------
-- DESIGN NOTES:
-- • Multiple thumbnail sizes per file for responsive UI
-- • Generated asynchronously after file upload
-- • Only created for image/video files that support thumbnails
-- -----------------------------------------------------------------------------
CREATE TABLE "file_thumbnail" (
      "id" uuid UNIQUE PRIMARY KEY NOT NULL,
      "file_id" uuid NOT NULL,                        -- References file.id
      "size" bigint NOT NULL,                         -- Thumbnail file size in bytes
      "size_type" SizeType NOT NULL,                  -- small/medium/large variant
      "storage_path" varchar(255) NOT NULL,           -- Thumbnail storage location
      "mime_type" varchar(100) NOT NULL DEFAULT 'image/jpeg',  -- Usually JPEG for thumbnails
      "created_at" timestamp DEFAULT CURRENT_TIMESTAMP
);


-- =====================================================================================
-- INDEXES - Performance Optimisation
-- =====================================================================================
CREATE UNIQUE INDEX ON "user" ("email");

CREATE INDEX ON "file" ("owner_id");

CREATE INDEX ON "file" ("parent_id");

CREATE INDEX ON "file" ("type");

CREATE INDEX ON "file" ("is_deleted");

CREATE INDEX ON "file" ("name", "parent_id");

CREATE INDEX ON "file" ("file_extension");

CREATE INDEX ON "file" ("created_at");

CREATE INDEX ON "file_thumbnail" ("file_id");

CREATE UNIQUE INDEX ON "file_thumbnail" ("file_id", "size_type");

COMMENT ON TABLE "file" IS 'CHECK constraints:
- If type = ''folder'' then mime_type IS NULL AND size IS NULL AND storage_path IS NULL
- If type = ''file'' then mime_type IS NOT NULL AND size IS NOT NULL AND storage_path IS NOT NULL
- size >= 0
- Prevent circular references in parent_id
';

COMMENT ON COLUMN "file"."mime_type" IS 'null for folders, required for files';

COMMENT ON COLUMN "file"."size" IS 'null for folders, required for files';

COMMENT ON COLUMN "file"."file_extension" IS 'extracted from filename, preserves user intent';

COMMENT ON COLUMN "file"."is_deleted" IS 'soft delete';

COMMENT ON COLUMN "file"."deleted_at" IS 'timestamp when soft deleted';

COMMENT ON COLUMN "file"."parent_id" IS 'null for root level items';

COMMENT ON COLUMN "file_thumbnail"."storage_path" IS 'storage location';

ALTER TABLE "file" ADD FOREIGN KEY ("owner_id") REFERENCES "user" ("id");

ALTER TABLE "file" ADD FOREIGN KEY ("parent_id") REFERENCES "file" ("id");

ALTER TABLE "file_thumbnail" ADD FOREIGN KEY ("file_id") REFERENCES "file" ("id");
