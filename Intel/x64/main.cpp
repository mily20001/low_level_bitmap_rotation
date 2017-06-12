#include <SFML/Window.hpp>
#include <SFML/Graphics.hpp>
#include <fstream>
#include <iostream>
#include <stdint.h>
#include <cstring>
#include <cstdlib>
#include <string>
#include "f.h"
//#define NO_INPUT

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

int width, height, padding;

int maxx(int a, int b)
{
    if(a > b)
        return a;
    return b;
}

void recalc_wh(int o_width, int o_height, int rot)
{
    if(rot==1 || rot==3)
    {
        height = o_width;
        width = o_height;
    }
    else
    {
        height = o_height;
        width = o_width;
    }

    padding = width%4;
}

void update_headers(BITMAPFILEHEADER* bfh, BITMAPINFOHEADER* bih)
{
    bfh->bfSize = (3 * width + padding) * height + bfh->bfOffBits;
    bih->biHeight = height;
    bih->biWidth = width;
}

void do_final_bmp(char* pixels, char* out, BITMAPFILEHEADER bfh, BITMAPINFOHEADER bih)
{
    for(int i = 0; i < bfh.bfSize; i++)
    {
        out[i] = 0;
    }

    memcpy(out, &bfh, sizeof bfh);
    memcpy(out + sizeof(bfh), &bih, sizeof bih);

    int pos = bfh.bfOffBits;
    for(int i = 0; i < height; i++)
    {
            for(int j = 0; j < width; j++)
            {
                    out[pos++] = pixels[i * width * 3 + 3 * j];
                    out[pos++] = pixels[i * width * 3 + 3 * j + 1];
                    out[pos++] = pixels[i * width * 3 + 3 * j + 2];
            }
            pos += padding;
    }
}

int main()
{
    int rot = 1, kier, o_h, o_w;
    string inFile = "";
#ifndef NO_INPUT
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
#else
    FILE* file = fopen("kon2.bmp", "rb");
#endif

    BITMAPFILEHEADER bitmapfileheader;
    fread((char*)&bitmapfileheader, sizeof(BITMAPFILEHEADER), 1, file);

    BITMAPINFOHEADER bitmapinfoheader;
    fread((char*)&bitmapinfoheader, sizeof(BITMAPINFOHEADER), 1, file);

    o_w=bitmapinfoheader.biWidth;
    o_h=bitmapinfoheader.biHeight;

    recalc_wh(o_w, o_h, 0); //calculate initial padding

    fseek(file, bitmapfileheader.bfOffBits, SEEK_SET);

    char* pixels = new char[width*height*3];
    char out_pixels[width*height*3];
    char tmp[4];
    for(int i = 0; i < width*height; i++)
    {
        fread(tmp, 3, 1, file);
        pixels[i*3] = tmp[0];
        pixels[i*3+1] = tmp[1];
        pixels[i*3+2] = tmp[2];
        
        if((i+1) % width == 0)
        {
            fread(tmp, padding, 1, file);
        }
    }

    f(pixels, out_pixels, width, height, rot);

    recalc_wh(width, height, rot);
    update_headers(&bitmapfileheader, &bitmapinfoheader);

    char out[bitmapfileheader.bfSize+maxx(width, height)*3];

    do_final_bmp(out_pixels, out, bitmapfileheader, bitmapinfoheader);

//    FILE* file2 = fopen("sout.bmp", "wb");
//    fwrite(out, sizeof(char), sizeof(out), file2);

    sf::RenderWindow window(sf::VideoMode(width, height), "Obrazek obrocony o " + std::to_string(90*rot) + "st");
    sf::Texture texture;
    if (!texture.loadFromMemory(out, sizeof out))
        return EXIT_FAILURE;

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
                rot = ((++rot)%4);
                for(int i=0; i<width*height*3; i++)
                    pixels[i] = out_pixels[i];
                
                f(pixels, out_pixels, width, height, 1);

                recalc_wh(o_w, o_h, rot);
                update_headers(&bitmapfileheader, &bitmapinfoheader);
                do_final_bmp(out_pixels, out, bitmapfileheader, bitmapinfoheader);
                
//                 FILE* file2 = fopen("sout1.bmp", "wb");
//                 fwrite(out, sizeof(char), bitmapfileheader.bfSize, file2);
//                 fclose(file2);
                
                texture.loadFromMemory(out, bitmapfileheader.bfSize);
                window.create(sf::VideoMode(width, height), "Obrazek obrocony o " + std::to_string(90*rot) + "st");
                window.setFramerateLimit(30);
            }
        }
        sf::Sprite sprite(texture);
        window.clear();
        window.draw(sprite);
        window.display();
    }
    return EXIT_SUCCESS;
}
