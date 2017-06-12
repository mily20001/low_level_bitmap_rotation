#include <SFML/Window.hpp>
#include <SFML/Graphics.hpp>
#include <fstream>
#include <iostream>
#include <stdint.h>
#include <cstring>
#include "f.h"

#pragma pack(1)
typedef struct BITMAPFILEHEADER
{
    short bfType;
    int bfSize;
    short bfReserved1;
    short bfReserved2;
    int bfOffBits;
} BITMAPFILEHEADER;

typedef struct BITMAPINFOHEADER
{
    int biSize;
    int biWidth;
    int biHeight;
    short biPlanes;
    short biBitCount;
    int biCompression;
    int biSizeImage;
    int biXPelsPerMeter;
    int biYPelsPerMeter;
    int biClrUsed;
    int biClrImportant;
} BITMAPINFOHEADER;

#pragma pack()

using namespace std;

int main()
{
    int rot = 1, kier;
    string inFile = "";
    cout<<"Podaj nazwe pliku: "<<flush;
    cin>>inFile;

    FILE* file = fopen(inFile.c_str(), "rb");

    if(file == NULL)
    {
        cout<<"Blad przy otwieraniu pliku"<<endl;
        return -1;
    }

    cout<<"Podaj liczbe obrotow o 90st: "<<flush;
    cin>>rot;
    rot = rot%4;

    cout<<"Podaj kierunek obrotu (-1 - przeciwnie do wskazowek zegara, 1 - zgodnie ze wskazowkami zegara):"<<endl;
    cin>>kier;

    if(kier == -1)
    {
        rot = (4-rot)%4;
    }

    BITMAPFILEHEADER bitmapfileheader;
    fread((char*)&bitmapfileheader, sizeof(BITMAPFILEHEADER), 1, file);

    BITMAPINFOHEADER bitmapinfoheader;
    fread((char*)&bitmapinfoheader, sizeof(BITMAPINFOHEADER), 1, file);

    int padding = 0 ;
    if(bitmapinfoheader.biWidth % 4)
    {
        padding = 4 - (3*bitmapinfoheader.biWidth % 4);
    }

    fseek(file,bitmapfileheader.bfOffBits,SEEK_SET);

    char pixels[bitmapinfoheader.biWidth*bitmapinfoheader.biHeight*3];
    char out_pixels[bitmapinfoheader.biWidth*bitmapinfoheader.biHeight*3];
    char tmp[4];
    for(int i=0; i<bitmapinfoheader.biWidth*bitmapinfoheader.biHeight; i++)
    {
        fread(tmp, 3, 1, file);
        pixels[i*3]=tmp[0];
        pixels[i*3+1]=tmp[1];
        pixels[i*3+2]=tmp[2];
        if((i+1) % bitmapinfoheader.biWidth == 0)
        {
            fread(tmp, padding, 1, file);
        }
    }

    f(pixels, out_pixels, bitmapinfoheader.biWidth, bitmapinfoheader.biHeight, rot);

    if(rot==1 || rot==3)
    {
        int tmpW=bitmapinfoheader.biWidth;
        bitmapinfoheader.biWidth=bitmapinfoheader.biHeight;
        bitmapinfoheader.biHeight=tmpW;
        if(bitmapinfoheader.biWidth % 4)
            padding = 4 - (3*bitmapinfoheader.biWidth % 4);
        else
            padding = 0;
        bitmapfileheader.bfSize=(3*bitmapinfoheader.biWidth+padding)*bitmapinfoheader.biHeight+bitmapfileheader.bfOffBits;
    }

    char out[bitmapfileheader.bfSize];
    for(int i=0; i<bitmapfileheader.bfSize; i++)
    {
        out[i]=0;
    }

    memcpy(out, &bitmapfileheader, sizeof bitmapfileheader);
    memcpy(out+sizeof(bitmapfileheader), &bitmapinfoheader, sizeof bitmapinfoheader);

    int pos = bitmapfileheader.bfOffBits;
    for(int i=0; i<bitmapinfoheader.biHeight; i++)
    {
        for(int j=0; j<bitmapinfoheader.biWidth; j++)
        {
            out[pos++]=out_pixels[i*bitmapinfoheader.biWidth*3+3*j];
            out[pos++]=out_pixels[i*bitmapinfoheader.biWidth*3+3*j+1];
            out[pos++]=out_pixels[i*bitmapinfoheader.biWidth*3+3*j+2];
        }
        pos+=padding;
    }

//    FILE* file2 = fopen("sout.bmp", "wb");
//    fwrite(out, sizeof(char), sizeof(out), file2);

    sf::RenderWindow window(sf::VideoMode(bitmapinfoheader.biWidth, bitmapinfoheader.biHeight), "Obrazek");
    sf::Texture texture;
    if (!texture.loadFromMemory(out, sizeof out))
        return EXIT_FAILURE;
    sf::Sprite sprite(texture);

    window.setFramerateLimit(30);

    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
            if(event.type == sf::Event::MouseButtonPressed)
            {
                rot=((++rot)%4);
                cout<<"DONE"<<endl;

            }
        }
        window.clear();
        window.draw(sprite);
        window.display();
    }
    return EXIT_SUCCESS;
}
