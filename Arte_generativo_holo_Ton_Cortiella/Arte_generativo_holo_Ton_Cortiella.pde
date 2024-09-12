// Variables globales para simular fluidos complejos
float[][] velocidadX, velocidadY;  // Velocidades en la cuadrícula
int tamañoCuadricula = 120;        // Tamaño de la cuadrícula
float amortiguacion = 0.98;        // Factor de "amortiguación"
float fuerzaMaxima = 0.6;          // Máxima fuerza aplicada por el sistema
int desplazamientoTiempo = 0;      // Variable para cambiar los parámetros con el tiempo
float atractorX, atractorY;        // Puntos atractores que guiarán el sistema

void setup() {
  size(800, 800);
  background(0);
  noStroke();
  
  // Inicializar cuadrícula de velocidades
  velocidadX = new float[tamañoCuadricula][tamañoCuadricula];
  velocidadY = new float[tamañoCuadricula][tamañoCuadricula];
  
  // Inicializar puntos atractores en posiciones aleatorias
  atractorX = random(width);
  atractorY = random(height);
}

void draw() {
  background(0, 20);  // Fondo ligeramente transparente para rastros fluidos

  // Cambios suaves en la amortiguación y la fuerza con el tiempo
  amortiguacion = map(noise(desplazamientoTiempo * 0.01), 0, 1, 0.95, 0.99);  // Variación lenta de amortiguación
  float magnitudFuerza = map(noise(desplazamientoTiempo * 0.02), 0, 1, 0.1, fuerzaMaxima);  // Variación de la fuerza

  // Mueve los atractores de forma caótica pero suave
  atractorX += map(noise(desplazamientoTiempo * 0.03), 0, 1, -2, 2);
  atractorY += map(noise(desplazamientoTiempo * 0.04), 0, 1, -2, 2);

  // Limita el movimiento del atractor dentro del espacio
  atractorX = constrain(atractorX, 0, width);
  atractorY = constrain(atractorY, 0, height);

  // Aplicación automática de fuerzas en posiciones basadas en los atractores
  for (int i = 1; i < tamañoCuadricula - 1; i++) {
    for (int j = 1; j < tamañoCuadricula - 1; j++) {
      
      // Modificar la velocidad de cada celda según el ruido Perlin
      velocidadX[i][j] += (noise(i * 0.05, j * 0.05, desplazamientoTiempo * 0.01) - 0.5) * magnitudFuerza;
      velocidadY[i][j] += (noise(i * 0.05 + 100, j * 0.05 + 100, desplazamientoTiempo * 0.01) - 0.5) * magnitudFuerza;
      
      // Atractores caóticos: Las partículas son atraídas hacia los atractores en movimiento
      float dx = atractorX - map(i, 0, tamañoCuadricula, 0, width);
      float dy = atractorY - map(j, 0, tamañoCuadricula, 0, height);
      float distancia = dist(atractorX, atractorY, dx, dy);
      
      // Asegúrate de que la distancia no sea cero para evitar división por cero
      if (distancia > 0) {
        velocidadX[i][j] += (dx / distancia) * 0.05;
        velocidadY[i][j] += (dy / distancia) * 0.05;
      }

      // Aplica "amortiguación"
      velocidadX[i][j] *= amortiguacion;
      velocidadY[i][j] *= amortiguacion;
      
      // Convierte las coordenadas de la cuadrícula en posiciones en la pantalla
      float posX = map(i, 0, tamañoCuadricula, 0, width);
      float posY = map(j, 0, tamañoCuadricula, 0, height);
      
      // Calcular el ángulo para simular un efecto holográfico
      float angulo = atan2(velocidadY[i][j], velocidadX[i][j]) + desplazamientoTiempo * 0.01;
      float radio = dist(0, 0, velocidadX[i][j], velocidadY[i][j]);
      
      // Colores holográficos
      float r = (sin(angulo + desplazamientoTiempo * 0.02) * 127 + 128);
      float g = (sin(angulo + desplazamientoTiempo * 0.03) * 127 + 128);
      float b = (sin(angulo + desplazamientoTiempo * 0.04) * 127 + 128);
      
      // Agrega un brillo dinámico
      float brillo = map(radio, 0, 1, 0, 255);
      
      // Dibuja partículas fluidas con efecto holográfico
      fill(r, g, b, 150);  // Color basado en el ángulo
      ellipse(posX, posY, 10, 10);  // Partícula dibujada
    }
  }
  
  // Incrementa el tiempo para la variación temporal de los parámetros
  desplazamientoTiempo++;
}
