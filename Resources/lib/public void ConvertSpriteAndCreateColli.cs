public void ConvertSpriteAndCreateCollider (Color[] pixels) {
    for (int i = 0 ; i < pixels.Length ; i++ ) 
    { 
        // delete all black pixel (black is the circuit, white is the walls)
        if ((pixels[i].r==0 && pixels[i].g==0 && pixels[i].b==0 && pixels[i].a==1)) {
            pixels[i] = Color.clear;
        }
    }
    // Set a new texture with this pixel list
    newTexture.SetPixels(pixels);
    newTexture.Apply();

    // Create a sprite from this texture
    mySprite = Sprite.Create(newTexture, new Rect(0, 0, newTexture.width, newTexture.height), new Vector2(10.0f,10.0f), 10.0f, 0, SpriteMeshType.Tight,new Vector4(0,0,0,0),false);

    // Add it to our displayerComponent
    displayerComponent.GetComponent<SpriteRenderer>().sprite=mySprite;

    // Add the polygon collider to our displayer Component and get his path count
    polygonColliderAdded = displayerComponent.AddComponent<PolygonCollider2D>();

}
