int y = 1500; //staticValue
int x = 0; //randomValue
int a = 1500; //alpha

void settings() { //No se porque pero he usado el void settings, me daba error el codigo si no lo usaba.
  size(y, y);
}

void setup() {
 background(y,y,y);
 //line(0, y/2, y, y/2); //Son opcionales estas lineas, solo era una ayuda visual. :)
 //line(y/2, y, y/2, 0);

}

void draw() {
  stroke(0, a*y);
  line(y/2+x, y/2, y/2, 0+x);
  line(y/2-x, y/2, y/2, 0+x);
  line(y/2, y-x, y/2-x, y/2);
  line(y/2, y-x, y/2+x, y/2);
  x += random(5, 25);
  a -= x*a/y*2;

}

//He hecho el codigo para que siempre que cambies el valor de y todo se adapte y no se rompa nada, el valor random de X se puede cambiar
//a cualquier numero que seguira funcionando siempre. :) <3

//Por si quieres leer sobre como funciona a (alpha), le resta de 1500 que es mucho para un alpha además en el stroke se multiplica por y
//es decir 1500 mas, lo hago tan exagerado porque el momento en que el valor de a es 1 se multiplica por 1500 y sigue siendo completamente
//visible, en cuanto llega a 0 al multiplicarlo por y el resultado es 0, es para que pase de 100% de opacidad a 0% sin tener un degradado,
//he pensado que alomejor es una solucion un poco rara y quería explicarlo, no he usado ChatGPT pero si he ido tocando la formula.

//También he reutilizado mucho el valor y ya que recuerdo que dijiste algo de que querías el codigo limpio y tal.
