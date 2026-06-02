PImage photo;
ArrayList<ArrayList<PVector>> todosLosTallos;
ArrayList<Integer> coloresTallo;
ArrayList<Float> angulosTallo;
ArrayList<Float> velocidadesTallo;
boolean imagenCargada = false;

void setup() {
  size(940, 520);
  photo = loadImage("doss.jpg");
  if (photo != null) {
    photo.resize(width, height);
    photo.loadPixels();
    imagenCargada = true;
  } else {
    println("Error: No se pudo cargar la imagen 'doss.jpg'");
  }
  
  todosLosTallos = new ArrayList<ArrayList<PVector>>();
  coloresTallo = new ArrayList<Integer>();
  angulosTallo = new ArrayList<Float>();
  velocidadesTallo = new ArrayList<Float>();
  
  if (imagenCargada) generarSemillas();
}

void generarSemillas() {
  int paso = 8; 
  int contador = 0;
  
  for (int x = 0; x < width; x += paso) {
    for (int y = 0; y < height; y += paso) {
      int loc = x + y * width;
      if (loc >= photo.pixels.length) continue;
      
      color c = photo.pixels[loc];
      float r = red(c);
      float g = green(c);
      float b = blue(c);
      
      // PALETA COMPLETA: Fucsia, Celeste, Violeta, Morado
      // Detectamos cualquier tono con predominio de Rojo+Azul o Azul+Rojo
      boolean esFucsia = (r > 80 && b > 80 && g < 150); // Fucsia
      boolean esCeleste = (b > 80 && r < 150 && g < 150); // Celeste
      boolean esVioleta = (r > 60 && b > 60 && r < 200 && b < 200 && g < 180); // Violetas medios
      
      if (esFucsia || esCeleste || esVioleta) {
        ArrayList<PVector> nuevoTallo = new ArrayList<PVector>();
        PVector inicio = new PVector(x, y);
        nuevoTallo.add(inicio);
        
        todosLosTallos.add(nuevoTallo);
        coloresTallo.add(c); // Guardamos el color REAL del píxel
        
        // Ángulo inicial aleatorio
        angulosTallo.add(random(TWO_PI));
        
        // Velocidad variable para cada tallo (más lento: 0.5 a 1.2)
        velocidadesTallo.add(random(0.5, 1.2));
        
        contador++;
        if(contador > 400) break; 
      }
    }
  }
  println("Semillas generadas: " + todosLosTallos.size());
}

void draw() {
  background(0);
  
  // 1. IMAGEN BASE MÁS VISIBLE (Sutil, 85% de opacidad)
  if (imagenCargada) {
    tint(255, 220); 
    image(photo, 0, 0);
    noTint();
  }
  
  // 2. DIBUJAR LÍNEAS SUTILES
  noFill();
  
  for (int i = 0; i < todosLosTallos.size(); i++) {
    ArrayList<PVector> tallo = todosLosTallos.get(i);
    color c = coloresTallo.get(i);
    float angulo = angulosTallo.get(i);
    float velocidad = velocidadesTallo.get(i);
    
    // COLOR REAL DEL PÍXEL (Fucsia, Celeste, Violeta, etc.)
    // Usamos el color exacto pero con transparencia para sutileza
    stroke(red(c), green(c), blue(c), 180);
    strokeWeight(1.2);
    
    // PUNTO DE INICIO (Color real, un poco más grueso)
    PVector inicio = tallo.get(0);
    stroke(red(c), green(c), blue(c), 220);
    strokeWeight(3.5);
    point(inicio.x, inicio.y);
    
    // Halo sutil del punto
    stroke(red(c), green(c), blue(c), 60);
    strokeWeight(1.5);
    ellipse(inicio.x, inicio.y, 8 + sin(frameCount * 0.03 + i)*3, 8 + sin(frameCount * 0.03 + i)*3);
    
    // CRECER EL TALLO (MÁS LENTO)
    // Eliminamos el límite de tamaño para que fluya siempre
    PVector ultimo = tallo.get(tallo.size()-1);
    
    // Movimiento orgánico con Perlin Noise (más suave)
    float noiseVal = noise(ultimo.x * 0.008, ultimo.y * 0.008, frameCount * 0.002);
    float anguloActual = angulo + map(noiseVal, 0, 1, -PI/6, PI/6);
    
    // Apertura muy sutil (casi imperceptible)
    anguloActual += 0.002 * tallo.size();
    
    // PASO MUY LENTO (0.8 a 1.2 según la velocidad de la semilla)
    float paso = 0.8 * velocidad;
    float newX = ultimo.x + cos(anguloActual) * paso;
    float newY = ultimo.y + sin(anguloActual) * paso;
    
    // Si el punto sale de la pantalla, reiniciamos desde el origen
    if (newX < -10 || newX > width+10 || newY < -10 || newY > height+10) {
      tallo.clear();
      tallo.add(new PVector(inicio.x, inicio.y));
      // Nuevo ángulo para variar
      angulosTallo.set(i, random(TWO_PI));
    } else {
      tallo.add(new PVector(newX, newY));
    }
    
    // DIBUJAR LÍNEA ORGÁNICA Y SUTIL
    stroke(red(c), green(c), blue(c), 100); // Más transparente para sutileza
    strokeWeight(0.8);
    beginShape();
    for (PVector p : tallo) {
      curveVertex(p.x, p.y);
    }
    endShape();
  }
}

void mousePressed() {
  // Reiniciar al hacer clic
  todosLosTallos.clear();
  coloresTallo.clear();
  angulosTallo.clear();
  velocidadesTallo.clear();
  if (imagenCargada) generarSemillas();
}