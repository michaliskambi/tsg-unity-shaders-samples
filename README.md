# Shadery

## Wstęp

### Fixed-function

Oryginalny, najstarszy OpenGL fixed-function miał takie podejście do renderowania:

  glLoadMatrix, glMultMatrix (and shortcuts like glLoadIdentity, glTranslate, glScale...)

    glBegin(...)

      gl(... some vertex attrib, like glTexCoord, glMultiTexCoord, glMaterial...)
      glVertex(...);

      gl(... some vertex attrib, like glTexCoord, glMultiTexCoord, glMaterial...)
      glVertex(...);

      gl(... some vertex attrib, like glTexCoord, glMultiTexCoord, glMaterial...)
      glVertex(...);

      ....

    glEnd();

To API już nie istnieje w nowszych OpenGLach (jest deprecated w GL 3.0, wyrzucone w 3.1, a nawet na starszych GLach --- mocno niezalecane jako bardzo nieefektywne), jest zastąpione vertex arrays ładowanymi przez VBO. Ale podstawowa koncepcja pozostała: renderowanie to podawanie zbioru vertexów, każdy vertex ma jakieś atrybuty.

### Multi-texturing

Co można robić ciekawego per-vertex?

  glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, constColor);
  glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE_ARB);
  glTexEnvf(GL_TEXTURE_ENV, GL_COMBINE_ALPHA_ARB, GL_MODULATE);
  glTexEnvf(GL_TEXTURE_ENV, GL_SOURCE0_ALPHA_ARB, GL_TEXTURE);
  glTexEnvf(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA_ARB, GL_SRC_ALPHA);
  glTexEnvf(GL_TEXTURE_ENV, GL_SOURCE1_ALPHA_ARB, GL_CONSTANT_ARB);
  glTexEnvf(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA_ARB, GL_SRC_ALPHA);

Co to znaczy? Że wynikowa alpha to "texure.alpha * constColor.alpha". Ewidentnie, chcemy wykonywać dowolne operacje arytmetyczne na kolorach, a to API jest ograniczeniem.

Stąd pomysły: hej, może udostępnijmy język do takich obliczeń?

### Shadery

1. Jest funkcja per-vertex. Typowe zastosowania to zrobić to co klasyczny OpenGL robił dla glVertex:

    transform it by projection * modelview matrices,
    calculate per-vertex values like color from lighting

      color =
        material emission +
        scene ambient * mat ambient +
        for each light: (
          light ambient * mat ambient +
          light diffuse * mat diffuse * diffuse factor +
          light specular .... etc.).

2. OpenGL

* buduje primitives z vertexów (dla niektórych - vertexy są shared, np. triangle strip/fan)
* sprawdza je pod kątem backface culling
* rasteryzuje, czyli zamienia na zbiór pixeli (dla odcinka, algorytm Bresenhama; jak wypełnić trójkąt jest już wtedy oczywiste (Ok, są tu caveats na brzegach --- wypełnienie tak żeby 2 sąsiednie trójkąty nie miały szczeliny ale zarazem każdy pixel był zamalowany tylko raz; no i później jest kwestia anti-aliasingu)).

3. Pozostaje zrobić coś per-fragment, czyli per-pixel. Mamy

* interpolowane wartości z vertex shadera (np. kolory, wektory normalne, współrzędne textury),
* mamy zmienne uniform (stałe dla całego shadera; w Unity, to są po prostu właściwości materiału; w tym textury)

Fragment shader miesza je jak chce.

### Języki shaderów

Początkowe języki shaderów wyglądały bardziej jak asembler. See http://en.wikipedia.org/wiki/ARB_assembly_language

Potem powstały bardziej wysoko-poziomowe języki, nieco C-podobne, w dokumentacji zazwyczaj mówi się że były zainspirowane przez http://en.wikipedia.org/wiki/RenderMan_Shading_Language .

* GLSL - specyficzny dla OpenGLa. Bardzo wygodny kiedy piszemy OpenGL-only program, bo shadery GLSL ładujemy bezpośrednio przez API OpenGLa, OpenGL daje nam trywialne funkcje do kompilacji, linkowania etc.

* Cg - by NVidia. Kompilowany do różnych innych języków shaderów. Tego używany kiedy piszemy program który może działać pod OpenGLa lub Direct3D. Tego używamy w 99% w Unity, bo dla standalone Windowsa renderer używa Direct3D a reszta świata (Android, iOS, WebGL..) używa OpenGLa/OpenGLESa.

* HLSL - cośtam Direct3D podobne.

* Są jeszcze bardziej wysoko-poziomowe konstrukcje jak http://libsh.org/ ale to już Was raczej zupełnie nie interesuje.

### Specyfika językow shaderów

* Kilka wejść (vertex, fragment).
* Wbudowane typy vertex/matrix. Mają masę funkcji pomocniczych i konstruktorów. Są operatory "swizzle" to wyciągania komponentów vektorów w dowolnej kolejności.
* Wbudowane typy do textur --- które są "czarną skrzynką" dla shaderów i mogą być odczytywane tylko przez odpowiednie funkcje.
* Są specjalne "low-cost" wersje floatów: half, fixed.
  half
      s10e5 ("fp16") floating point w/ IEEE semantics
  fixed
      S1.10 fixed point, clamping to [-2, 2)
  Crude guideline: fixed do kolorów, half do reszty.
* Jest normalny, szczelny bool i array.
* Nie ma stringów, bo przecież nie ma żadnego I/O poza kolorami.
* Parametry własnych funkcji: są tylko in, out lub inout. Nie ma pointerów. Rekurencja *nie* dopuszczalna. To oznacza w praktyce że kompilator shaderów może (i typowo robi) "inline" całości i po skompilowaniu nie ma już żadnych funkcji.
* Są normalne if, for, while, do-while. Z haczykiem że wiele shaderów jest wykonywanych równolegle. Na starszych GPU, obie gałęzie if są wykonywane (tylko 1 mnożona razy 0), a for biegnie do max mozliwej wartości. Na nowszych GPU, przynajmniej pętle są bardziej "prawdziwe", ale ciągle grupy shaderów (np. 16 sąsiednich fragmentów) mają ten sam stan.

Generalnie, see Cg docs, przede wszystkim:
* http://http.developer.nvidia.com/Cg/Cg_language.html
* http://http.developer.nvidia.com/Cg/index_stdlib.html

# Część praktyczna

## Demo: proste nałożenie textury (Tex.shader), diffuse (SimpleDiffuse.shader).

Zadanie:
1. Zmień przykład diffuse w toon shading. Wygląda dziwnie, dlaczego?
2. Zmień żeby obliczać oświetlenie per-fragment (cieniowanie Phonga, nie Gourauda), wtedy toon zadziała ładnie.
3. Tex.shader zmień żeby mieszał 2 textury, wybierz jaśniejszą.

## Surface shadery.

Idea: piszemy funkcję "surf" która jest wkładana do środka shadera który zajmuje się obliczaniem oświetlenia. My zajmujemy się podaniem bazowego koloru (mieszamy textury, kolory...), Unity robi resztę. Dobre wtedy (i tylko wtedy) kiedy chcemy skorzystać ze standardowego oświetlenia Unity.

http://docs.unity3d.com/460/Documentation/Manual/SL-SurfaceShaderExamples.html

## Textury advanced

* Nearest vs bilinear,
* anisotropic,
* kompresja GPU (S3TC i podobne)
* Rodzaje textur:
  * 2d,
  * cubemap,
  * 3D (volumetric textures), http://docs.unity3d.com/Manual/class-Texture3D.html .

  Są jeszcze render texture, chociaż dla shaderów to po prostu 2d.

  Textury 2D ale provided z movie http://docs.unity3d.com/Manual/class-MovieTexture.html , czasami mogą być useful. Po stronie shaderów to oczywiście zwykłe textury 2D, ale Unity załatwia za Was rozpakowanie i odtwarzanie filmiku do sekwencji klatek 2D.

## Własna woda, własny bump mapping + reflection. Gotowe demo z materiałami prepare.

Cubemapy. See http://docs.unity3d.com/ScriptReference/Camera.RenderToCubemap.html . Próbkowanie kierunkiem.

Wyciąagnie normalek stąd: http://docs.unity3d.com/460/Documentation/Manual/SL-SurfaceShaderExamples.html

Planowałem przygotować gotowe demo którym moglibyśmy się bawić, ale nie zdążyłem... Spróbujemy zrobić na bieżąco?:)

## Shadery multipass w Unity.

Demo: Custom/Emboss

## Shader fallback w Unity.

## Textury proceduralne.

* kolorki.
* zastosowanie smooth noise, z textury.
* discard w shaderach - jakis otwor zrobiony proceduralnie.

## Image effects w Unity.

## Demo animujące shaderem vertexy:

* zmieniaj vertex w zaleznosci od tekstury. proste górki wynikające z noise.
* zmieniaj transformacje shaderem, np. przesun.
* mention disadvantages: ustawiaj recznie culling box

### Co pominąłem?

#### Przynajmniej w OpenGLu, są i inne rodzaje shaderów

* Geometry shaders (zmień prymitywy i vertexy)
* Tesselation, evaluation shaders
* Compute shaders. Akurat odpowiednik tego dla Direct3D jest obsługiwany przez Unity, it seems: http://docs.unity3d.com/Manual/ComputeShaders.html . Ale to nie do normalnych zastosowań, więc na chwilę zapomnijcie o tym:)

See https://www.opengl.org/wiki/Shader po początkowe linki.

### Many cool stuff possible with shaders:

* PRT
* 3d volumetric fog
* parallax mapping, http://michalis.ii.uni.wroc.pl/michaliswiki/II/ProgramowanieGier/WykladParallaxMappingPRT

# Timescale

* timescale 0 specjalny.
* timescale i fizyka.

# Asset bundles

* asset bundle - jak budowac w U4, jak w U5. Jak pobierać i rozpakowywać. Są per-platform, beware!
* asset importer w U5, do bundles, do texture properties.
