name := "enterprise-blockchain"
version := "0.1.0"
scalaVersion := "3.3.1"

lazy val root = (project in file("."))
  .settings(
    libraryDependencies ++= Seq(
      // Akka for actor-based concurrency
      "com.typesafe.akka" %% "akka-actor-typed" % "2.8.5",
      "com.typesafe.akka" %% "akka-stream" % "2.8.5",
      "com.typesafe.akka" %% "akka-http" % "10.5.3",

      // Cats for functional programming
      "org.typelevel" %% "cats-core" % "2.10.0",
      "org.typelevel" %% "cats-effect" % "3.5.2",

      // Web3
      "org.web3j" % "core" % "4.10.0",
      "org.web3j" % "crypto" % "4.10.0",

      // JSON
      "io.circe" %% "circe-core" % "0.14.6",
      "io.circe" %% "circe-generic" % "0.14.6",
      "io.circe" %% "circe-parser" % "0.14.6",

      // Database
      "com.typesafe.slick" %% "slick" % "3.5.0",
      "com.typesafe.slick" %% "slick-hikaricp" % "3.5.0",
      "org.postgresql" % "postgresql" % "42.6.0",

      // Logging
      "ch.qos.logback" % "logback-classic" % "1.4.11",
      "com.typesafe.scala-logging" %% "scala-logging" % "3.9.5",

      // Testing
      "org.scalatest" %% "scalatest" % "3.2.17" % Test,
      "com.typesafe.akka" %% "akka-actor-testkit-typed" % "2.8.5" % Test
    )
  )

scalacOptions ++= Seq(
  "-deprecation",
  "-feature",
  "-unchecked",
  "-Xfatal-warnings",
  "-language:higherKinds",
  "-language:implicitConversions"
)
