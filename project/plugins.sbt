lazy val V = new {
  val scalafix  = "0.14.0"
  val scalafmt  = "2.5.4"
  val updates   = "0.6.3"
  val sbt       = "2.1.0"
  val tpolecat  = "0.5.2"
  val buildInfo = "0.13.1"
  val assembly  = "2.3.1"
}

addSbtPlugin("com.timushev.sbt" % "sbt-updates"   % V.updates)
addSbtPlugin("ch.epfl.scala"    % "sbt-scalafix"  % V.scalafix)
addSbtPlugin("org.scalameta"    % "sbt-scalafmt"  % V.scalafmt)
addSbtPlugin("com.github.sbt"   % "sbt-git"       % V.sbt)
addSbtPlugin("org.typelevel"    % "sbt-tpolecat"  % V.tpolecat)
addSbtPlugin("com.eed3si9n"     % "sbt-buildinfo" % V.buildInfo)
addSbtPlugin("com.eed3si9n"     % "sbt-assembly"  % V.assembly)
