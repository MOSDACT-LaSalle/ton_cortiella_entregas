
/*---------------------------------
 Name: Ton cortiella Valls
 Date: Sept 2024 (Last Act.)
 Tittle:  Cloth Simu
 Description:

 Esta obra es un simulador de una tela, es divertido interactuar con ella
 clicandola puedes destruirla, también hay unos controladores de viento,
 con el sistema de la sala inmersiva de IASLab pordía ser una pequeña experiencia
 para usar con el sistema de In n Out que implementaran durante este Septiembre de
 2024 para la sala inmersiva de la Salle. 
 
 Este sistema permite al publico tocar la pantalla y poder interactuar con la obra
 asi destruyendo la tela y viendo como poco a poco de una malla cuadriculada 
 se logra hacer una pieza organica y maleable.
 
 Links:
https://sojamo.de/libraries/controlP5/
https://processing.org/reference/class.html
https://processing.org/reference/this.html
https://en.wikipedia.org/wiki/Verlet_integration
https://www.reddit.com/r/Unity3D/comments/pks6ys/i_learned_about_verlet_integration_thanks_to/
 -----------------------------------*/


import controlP5.*; // Librería para los controles (sliders) de Andreas Schelegel

// Clase que representa cada punto en la tela, la tela son puntos instanciados en 
// el espacio unidos posteriormente por vectores. Le damos el valor de posicion 
// (inicial), ultimaPosicion (para trackear dónde se mueven los puntos) y aceleración,
// funcion que usaremos para el movimiento.

// Creamos también el estado de fijado en booleanada 0 o 1, para aplicarlo a los
// puntos de arriba de la tela.

class Punto {
  PVector posicion;
  PVector ultimaPosicion;
  PVector aceleracion;
  boolean fijado = false;

  Punto(float x, float y) {
    posicion = new PVector(x, y);
    ultimaPosicion = new PVector(x, y);
    aceleracion = new PVector(0, 0); //empieza sin aceleración.
  }
  
// Esta función controla el tiempo para hacer funciones para hacer calculos con los 
// valores de posición, ultimaPosicion y acceleracion. Asi podemos calcular la velocidad 
// y la proximaPosicion que tendran las instancias.
// El codigo hace uso las funciones de Verlet Integration para actualizar la posición. 

  void actualizar(float tiempo) {
    if (!fijado) {
      PVector velocidad = PVector.sub(posicion, ultimaPosicion);
      PVector proximaPosicion = PVector.add(posicion, velocidad);
      proximaPosicion.add(PVector.mult(aceleracion, tiempo * tiempo));
      
      ultimaPosicion.set(posicion); //Guarda la posición actual a ultimaPosicion.
      posicion.set(proximaPosicion); // Actualiza la posición actual con el calculo de promixaPosicion.

      aceleracion.mult(0); // Resetear aceleración después de actualizar sino acababa llegando a velocidades infinitas.
    }
  }

 // Aplica una fuerza al punto, sumandola al vector de aceleración.
  void aplicarFuerza(PVector fuerza) {
    aceleracion.add(fuerza);
  }

// Fijamos los puntos superiores para que la tela no salga volando, activamos la boleana.

  void fijar() {
    fijado = true;
  }

// Dibujamos la class Punto como una elipse.

  void dibujar() {
    ellipse(posicion.x, posicion.y, 4, 4);
  }
}

// Clase que representa un enlace entre dos puntos en la tela, cada enlace tiene una distancia 
// en reposo y se puede estirar hasta una distancia máxima antes de romperse.
// La rigidez determina cuán resistente es el enlace a estirarse.

class Enlace {
  Punto p1, p2;
  float distanciaDescanso;
  float distanciaMaxima = 100;
  float rigidez = 0.5;

  Enlace(Punto p1, Punto p2, float distanciaDescanso) {
    this.p1 = p1;
    this.p2 = p2;
    this.distanciaDescanso = distanciaDescanso;
  }

 // Resuelve la física del enlace, asegurando que los puntos mantengan la distancia correcta. 
 // Calcula la diferencia entre los puntos, despues la distancia entre los puntos y finalmente si la distancia
 // supera la distanciaMaxima especificada (100) devuelve la funcion y no aplica el calculo.

  void resolver() {
    PVector diferencia = PVector.sub(p1.posicion, p2.posicion);
    float distancia = diferencia.mag();
    
    if (distancia > distanciaMaxima) {
      return;
    }
    
 // Calcula cuánto deben moverse los puntos para restaurar la distancia en reposo.
 
    float diferenciaNormalizada = (distanciaDescanso - distancia) / distancia;
    PVector traslacion = PVector.mult(diferencia, 0.5 * diferenciaNormalizada * rigidez);

    if (!p1.fijado) {
      p1.posicion.add(traslacion); // Mueve el primer punto, a menos que esté fijado.
    }

    if (!p2.fijado) {
      p2.posicion.sub(traslacion); // Mueve el segundo punto, a menos que esté fijado, la continuación de la cadena.
    }
  }
  
 // Verifica si el punto medio del enlace está cerca de otro punto concreto.

  boolean cercaDe(PVector punto, float umbral) {
    PVector puntoMedio = PVector.add(p1.posicion, p2.posicion).mult(0.5);
    return PVector.dist(puntoMedio, punto) < umbral;
  }


  // Dibuja el enlace como una línea entre los dos puntos.

  void dibujar() {
    float distancia = PVector.dist(p1.posicion, p2.posicion);
    int colorEnlace = calcularColor(distancia);
    stroke(colorEnlace);
    line(p1.posicion.x, p1.posicion.y, p2.posicion.x, p2.posicion.y);
  }

  // Calcula el color del enlace en función de su longitud (distancia entre puntos) para hacer que la tensión se pueda
  // visualizar con el cambio de color, azul poca tensión, rojo gran tensión.
  
  int calcularColor(float distancia) {
    
    // Rango de colores basado en la distancia
    
    float distanciaMin = 0;
    float distanciaMax = 60;
    float distanciaNorm = constrain((distancia - distanciaMin) / (distanciaMax - distanciaMin), 0, 1);
    
    color azul = color(0, 100, 255);
    color verde = color(0, 255, 100);
    color rojo = color(255, 100, 100);
    
    //interpolacion de los colores entre azul verde y rojo
    
    color color1 = lerpColor(azul, verde, distanciaNorm);
    color color2 = lerpColor(verde, rojo, distanciaNorm);
    return lerpColor(color1, color2, distanciaNorm);
  }
}

// Clase para representar las partículas de estrellas de cuando haces un click

class Particula {
  PVector posicion;
  PVector velocidad;
  float duracion;
  
  Particula(PVector posicion) {
    this.posicion = posicion.copy();
    this.velocidad = PVector.random2D().mult(random(2, 5));
    this.duracion = 150;
  }
  
  void actualizar() {
    posicion.add(velocidad);
    duracion -= 10;
  }
  
  void dibujar() {
    noStroke();
    fill(255, 255, 128, duracion);
    dibujarEstrella(posicion.x, posicion.y, 2, 4, 5);
  }
  
  boolean estaMuerta() {
    return duracion <= 0;
  }
  
    // Dibuja una estrella con los radios y el número de puntos concretos.
    
  void dibujarEstrella(float x, float y, float radio1, float radio2, int numPuntos) {
    float angulo = TWO_PI / numPuntos;
    float medioAngulo = angulo / 2.0;
    beginShape();
    for (float a = 0; a < TWO_PI; a += angulo) {
      float sx = x + cos(a) * radio2;
      float sy = y + sin(a) * radio2;
      vertex(sx, sy);
      sx = x + cos(a + medioAngulo) * radio1;
      sy = y + sin(a + medioAngulo) * radio1;
      vertex(sx, sy);
    }
    endShape(CLOSE);
  }
}

// Sistema de partículas que administra varias partículas de estrellas

class SistemaParticulas {
  ArrayList<Particula> particulas = new ArrayList<Particula>();
  
  void agregarParticulas(PVector posicion, int cantidad) {
    for (int i = 0; i < cantidad; i++) {
      particulas.add(new Particula(posicion));
    }
  }
  
 // Actualiza todas las partículas y elimina las que ya han muerto.

  void actualizar() {
    for (int i = particulas.size() - 1; i >= 0; i--) {
      Particula p = particulas.get(i);
      p.actualizar();
      if (p.estaMuerta()) {
        particulas.remove(i);
      }
    }
  }
 
 // Dibuja todas las partículas activas.
   
  void dibujar() {
    for (Particula p : particulas) {
      p.dibujar();
    }
  }
}

  // Declaración de la librería ControlP5 y los sliders para controlar el viento.
ControlP5 cp5;
Slider vientoSliderX; //Slider del viento en el eje X.
Slider vientoSliderY; //Slider del viento en el eje Y.


  // Parámetros de la malla de puntos.

int columnas = 60;
int filas = 40;
float separacion = 10;
ArrayList<Punto> puntos = new ArrayList<Punto>();
ArrayList<Enlace> enlaces = new ArrayList<Enlace>();
SistemaParticulas sistemaParticulas = new SistemaParticulas();

PVector fuerzaViento = new PVector(0, 0);

void setup() {
  size(1200, 800);

  // Crear la malla de puntos
  for (int y = 0; y < filas; y++) {
    for (int x = 0; x < columnas; x++) {
      Punto p = new Punto(x * separacion, y * separacion); 
      if (y == 0) {
        p.fijar(); // Fijar la fila superior
      }
      puntos.add(p);

      if (x > 0) {
        Punto izquierda = puntos.get(puntos.size() - 2);
        enlaces.add(new Enlace(p, izquierda, separacion));
      }
      if (y > 0) {
        Punto arriba = puntos.get((y - 1) * columnas + x);
        enlaces.add(new Enlace(p, arriba, separacion));
      }
    }
  }
  
  // Configuración de los sliders para el viento.
  
  cp5 = new ControlP5(this);
  vientoSliderX = cp5.addSlider("fuerzaVientoX")
    .setPosition(width - 220, 20)
    .setSize(200, 20)
    .setRange(-0.14, 0.14) 
    .setValue(0)
    .setLabel("Viento X");
  
  vientoSliderY = cp5.addSlider("fuerzaVientoY")
    .setPosition(width - 220, 60)
    .setSize(200, 20)
    .setRange(-0.14, 0.14)
    .setValue(0)
    .setLabel("Viento Y");
}

void draw() {
  background(0);

  // Actualizar la fuerza del viento con los valores de los sliders.
  
  fuerzaViento.set(vientoSliderX.getValue() / 7, vientoSliderY.getValue() / 7);

  // Aplicar gravedad.
  
  for (Punto p : puntos) {
    p.aplicarFuerza(new PVector(0, 0.05)); // Gravedad reducida
  }
  
  // Aplicar viento.
  
  for (Punto p : puntos) {
    p.aplicarFuerza(fuerzaViento);
  }

  // Actualizar la física con varias iteraciones.
  
  int numActualizacionesFisica = 3;
  for (int i = 0; i < numActualizacionesFisica; i++) {
    for (Enlace enlace : enlaces) {
      enlace.resolver();
    }
    for (Punto p : puntos) {
      p.actualizar(1); 
    }
  }

  // Dibujar enlaces y puntos.
  
  for (Enlace enlace : enlaces) {
    enlace.dibujar();
  }
  for (Punto p : puntos) {
    p.dibujar();
  }

  // Dibujar partículas.
  
  sistemaParticulas.actualizar();
  sistemaParticulas.dibujar();
}

void mousePressed() {
  cortarTela(mouseX, mouseY, 20);
  sistemaParticulas.agregarParticulas(new PVector(mouseX, mouseY), 3); // Menos partículas
}

void cortarTela(float x, float y, float umbral) {
  PVector mousePosicion = new PVector(x, y);
  for (int i = enlaces.size() - 1; i >= 0; i--) {
    Enlace enlace = enlaces.get(i);
    if (enlace.cercaDe(mousePosicion, umbral)) {
      enlaces.remove(i);
    }
  }
}

  // Funciones de los sliders para actualizar el viento.

void fuerzaVientoX(float valor) {
  fuerzaViento.x = valor;
}

void fuerzaVientoY(float valor) {
  fuerzaViento.y = valor;
}
