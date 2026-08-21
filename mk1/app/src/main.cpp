#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "BiometricBridge.hpp"
#include "VaultController.hpp"
#include "crusader/VaultCrypto.hpp"

int main(int argc, char* argv[]) {
  if (!crusader::init()) {
    return 1;
  }

  // Sin fijar esto, Qt Quick Controls elige un estilo por plataforma
  // (Material en Android, Fusion/Basic en escritorio) -- fijar "Basic" en
  // todas partes hace que el movil se comporte igual que el escritorio
  // mientras desarrollas la interfaz.
  QQuickStyle::setStyle("Basic");

  QGuiApplication app(argc, argv);
  QGuiApplication::setOrganizationName("Crusader");
  QGuiApplication::setApplicationName("crusader");
  // En Wayland, el icono que enseña la barra de tareas del sistema no sale
  // de setWindowIcon() (eso solo afecta al icono dentro de la propia app,
  // p.ej. Alt+Tab de Qt) -- el compositor busca un .desktop instalado cuyo
  // nombre coincida con el app_id de la ventana. Este setDesktopFileName
  // fija ese app_id a "crusader", que tiene que coincidir con el nombre
  // del archivo crusader.desktop (ver el comentario en ese archivo).
  QGuiApplication::setDesktopFileName("crusader");
  app.setWindowIcon(QIcon(QStringLiteral(":/qt/qml/Crusader/qml/assets/crusader_icon.png")));

  crusader::gui::VaultController vault;
  crusader::gui::BiometricBridge biometric;

  QQmlApplicationEngine engine;
  engine.rootContext()->setContextProperty("vault", &vault);
  engine.rootContext()->setContextProperty("biometric", &biometric);

  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
      []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
  engine.loadFromModule("Crusader", "Main");

  return app.exec();
}
