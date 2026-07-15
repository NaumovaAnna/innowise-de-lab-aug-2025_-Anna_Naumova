-CREATE TABLE Data_Layers (
    "LayerID" SERIAL PRIMARY KEY,
    "LayerName" VARCHAR(50) UNIQUE NOT NULL,
    "Description" TEXT
);