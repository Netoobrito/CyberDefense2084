import processing.sound.*;

PImage telaInicioImg;
PImage nivel2Img;
PImage nivel3Img;
PImage nivel4Img;
PImage nivel5Img;
PImage gameOverImg;
PImage backgroundImg;
PImage vitoriaImg;
PImage droneImg;

SoundFile musica;
SoundFile somTiro;
SoundFile somExplosao;
SoundFile musicaGameOver;
SoundFile musicaVitoria;

ArrayList<Drone> drones;
ArrayList<Tiro> tiros;
ArrayList<Explosao> explosoes;

Jogador jogador;

int pontos = 0;
int vidas = 5;

int nivel = 1;
int metaNivel = 100;

int tempoSpawn = 0;
int dificuldade = 80;

boolean gameOver = false;
boolean telaInicio = true;
boolean venceu = false;

int tempoMensagemNivel = 0;

PFont fonte;

float anguloMira = 0;

void setup() {

  size(1000, 700);

  noSmooth();

  musica = new SoundFile(this, "musica.mp3");
  musica.amp(0.4);
  musica.loop();

  somTiro = new SoundFile(this, "tiro.wav");
  somTiro.amp(0.7);

  somExplosao = new SoundFile(this, "explosão.wav");
  somExplosao.amp(0.8);

  musicaGameOver = new SoundFile(this, "perdeu.mp3");
  musicaGameOver.amp(0.8);

  musicaVitoria = new SoundFile(this, "vitoria.mp3");
  musicaVitoria.amp(0.8);

  telaInicioImg = loadImage("image 1.png");
  nivel2Img = loadImage("image 2.png");
  nivel3Img = loadImage("image 3.png");
  nivel4Img = loadImage("image 4.png");
  nivel5Img = loadImage("image 5.png");
  gameOverImg = loadImage("image 6.png");
  backgroundImg = loadImage("image 7.png");
  vitoriaImg = loadImage("image 8.png");

  droneImg = loadImage("drone.png");

  jogador = new Jogador();

  drones = new ArrayList<Drone>();
  tiros = new ArrayList<Tiro>();
  explosoes = new ArrayList<Explosao>();

  fonte = createFont("Arial", 32);

  textFont(fonte);

  rectMode(CORNER);
}

void draw() {

  if (telaInicio) {

    telaInicial();
    return;
  }

  if (venceu) {

    telaVitoria();
    return;
  }

  if (gameOver) {

    telaGameOver();
    return;
  }

  fundoJogo();

  sistemaNiveis();

  if (tempoMensagemNivel > 0) {
    return;
  }

  controlarMira();

  jogador.mostrar();

  spawnDrones();

  atualizarTiros();

  atualizarDrones();

  atualizarExplosoes();

  colisao();

  HUD();
}

void telaInicial() {

  image(telaInicioImg, 0, 0, width, height);

  fill(255, 255, 0);

  textAlign(CENTER);

  textSize(28);

}

void telaGameOver() {

  image(gameOverImg, 0, 0, width, height);

  fill(255);

  textAlign(CENTER);

  textSize(26);

}

void telaVitoria() {

  image(vitoriaImg, 0, 0, width, height);

  fill(255);

  textAlign(CENTER);

  textSize(26);

}

void fundoJogo() {

  image(backgroundImg, 0, 0, width, height);

  fill(0, 0, 0, 70);

  rect(0, 0, width, height);

  fill(0, 180, 255);

  rect(0, height - 40, width, 40);

  stroke(0, 255, 255);

  for (int i = 0; i < width; i += 40) {

    line(i, height - 40, i + 20, height);
  }

  noStroke();
}

void controlarMira() {

  if (keyPressed) {

    if (key == 'a' || keyCode == LEFT) {

      anguloMira -= 0.05;
    }

    if (key == 'd' || keyCode == RIGHT) {

      anguloMira += 0.05;
    }
  }

  anguloMira = constrain(anguloMira, -1.2, 1.2);
}

void spawnDrones() {

  tempoSpawn++;

  if (tempoSpawn >= dificuldade) {

    drones.add(new Drone());

    tempoSpawn = 0;
  }
}

void atualizarTiros() {

  for (int i = tiros.size() - 1; i >= 0; i--) {

    Tiro t = tiros.get(i);

    t.mostrar();

    t.mover();

    if (t.y < 0 || t.x < 0 || t.x > width) {

      tiros.remove(i);
    }
  }
}

void atualizarDrones() {

  for (int i = drones.size() - 1; i >= 0; i--) {

    Drone d = drones.get(i);

    d.mostrar();

    d.mover();

    if (d.y > height - 40) {

      drones.remove(i);

      vidas--;

      if (vidas <= 0) {

        gameOver = true;

        musica.stop();

        musicaGameOver.play();
      }
    }
  }
}

void atualizarExplosoes() {

  for (int i = explosoes.size() - 1; i >= 0; i--) {

    Explosao e = explosoes.get(i);

    e.mostrar();

    e.atualizar();

    if (e.acabou()) {

      explosoes.remove(i);
    }
  }
}

void colisao() {

  for (int i = drones.size() - 1; i >= 0; i--) {

    Drone d = drones.get(i);

    for (int j = tiros.size() - 1; j >= 0; j--) {

      Tiro t = tiros.get(j);

      float distancia = dist(d.x, d.y, t.x, t.y);

      if (distancia < 45) {

        drones.remove(i);

        tiros.remove(j);

        pontos += 20;

        explosoes.add(new Explosao(d.x, d.y));

        somExplosao.stop();
        somExplosao.play();

        break;
      }
    }
  }
}

void HUD() {

  fill(0, 0, 0, 140);

  rect(10, 10, 260, 170);

  fill(0, 255, 255);

  textAlign(LEFT);

  textSize(28);

  text("Pontos: " + pontos, 25, 45);

  text("Vidas: " + vidas, 25, 85);

  text("Nível: " + nivel, 25, 125);

  text("Meta: " + metaNivel, 25, 165);
}

void sistemaNiveis() {

  if (pontos >= metaNivel && nivel < 5 && tempoMensagemNivel <= 0) {

    nivel++;

    metaNivel += 100;

    dificuldade -= 10;

    vidas = 5;

    drones.clear();
    tiros.clear();

    tempoMensagemNivel = 240;
  }

  if (tempoMensagemNivel > 0) {

    tempoMensagemNivel--;

    if (nivel == 2) {
      image(nivel2Img, 0, 0, width, height);
    }

    if (nivel == 3) {
      image(nivel3Img, 0, 0, width, height);
    }

    if (nivel == 4) {
      image(nivel4Img, 0, 0, width, height);
    }

    if (nivel == 5) {
      image(nivel5Img, 0, 0, width, height);
    }

    return;
  }

  if (nivel == 5 && pontos >= 500) {

    venceu = true;

    musica.stop();

    musicaVitoria.play();
  }
}

void keyPressed() {

  if (telaInicio && keyCode == ENTER) {

    telaInicio = false;
  }

  if ((gameOver || venceu) && (key == 'r' || key == 'R')) {

    reiniciarJogo();
  }

  if (key == ' ') {

    float tiroX = jogador.x + 40 + sin(anguloMira) * 90;

    float tiroY = jogador.y + 10 - cos(anguloMira) * 90;

    float velocidadeX = sin(anguloMira) * 8;

    float velocidadeY = -cos(anguloMira) * 8;

    tiros.add(new Tiro(tiroX, tiroY, velocidadeX, velocidadeY));

    somTiro.stop();
    somTiro.play();
  }
}

void reiniciarJogo() {

  pontos = 0;

  vidas = 5;

  nivel = 1;

  metaNivel = 100;

  dificuldade = 80;

  drones.clear();

  tiros.clear();

  explosoes.clear();

  gameOver = false;

  venceu = false;

  telaInicio = true;

  musicaGameOver.stop();
  musicaVitoria.stop();

  musica.loop();

  loop();
}

class Jogador {

  float x;
  float y;

  Jogador() {

    x = width/2 - 40;

    y = height - 100;
  }

  void mostrar() {

    // BASE
    fill(40, 40, 60);

    rect(x, y, 80, 40);

    fill(20, 20, 30);

    rect(x + 5, y + 5, 70, 30);

    fill(0, 255, 255);

    rect(x + 12, y + 12, 12, 12);
    rect(x + 30, y + 12, 12, 12);
    rect(x + 48, y + 12, 12, 12);

   pushMatrix();

    translate(x + 40, y + 10);

    rotate(anguloMira);

    fill(120, 255, 120);

    rect(-5, -90, 10, 90);

    fill(0, 255, 100);

    rect(-8, -95, 16, 10);

    popMatrix();

    fill(0, 255, 0);

    rect(x + 32, y + 2, 16, 16);
  }
}

class Drone {

  float x;
  float y;

  float velocidade;

  Drone() {

    x = random(80, width - 80);

    y = -100;

    velocidade = random(1.0, 2.5) + nivel * 0.3;
  }

  void mostrar() {

    imageMode(CENTER);

    image(droneImg, x, y, 90, 90);

    imageMode(CORNER);
  }

  void mover() {

    y += velocidade;
  }
}

class Tiro {

  float x;
  float y;

  float velX;
  float velY;

  Tiro(float novoX, float novoY, float vx, float vy) {

    x = novoX;

    y = novoY;

    velX = vx;

    velY = vy;
  }

  void mostrar() {

    fill(255, 255, 0);

    rect(x - 3, y - 12, 6, 12);

    fill(255, 150, 0);

    rect(x - 2, y, 4, 4);
  }

  void mover() {

    x += velX;

    y += velY;
  }
}

class Explosao {

  float x;
  float y;

  float tamanho = 10;

  float alpha = 255;

  Explosao(float novoX, float novoY) {

    x = novoX;
    y = novoY;
  }

  void atualizar() {

    tamanho += 5;

    alpha -= 12;
  }

  void mostrar() {

    noFill();

    strokeWeight(4);

    stroke(0, 255, 255, alpha);

    ellipse(x, y, tamanho, tamanho);

    stroke(255, 0, 120, alpha);

    ellipse(x, y, tamanho * 0.7, tamanho * 0.7);

    stroke(255, alpha);

    ellipse(x, y, tamanho * 0.4, tamanho * 0.4);

    noStroke();
  }

  boolean acabou() {

    return alpha <= 0;
  }
}
