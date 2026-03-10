import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      bottomNavigationBar: const BottomNavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// HEADER
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: const BoxDecoration(
                  color: Color(0xFF1B8E3E),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [

                    /// Greeting Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Good Morning,",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Rajesh Kumar 👋",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),

                        Row(
                          children: [

                            /// Notification
                            Stack(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.white24,
                                  child: Icon(Icons.notifications, color: Colors.white),
                                ),
                                Positioned(
                                  right: 3,
                                  top: 3,
                                  child: Container(
                                    height: 8,
                                    width: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              ],
                            ),

                            const SizedBox(width: 10),

                            /// Avatar
                            const CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: Text(
                                "RK",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Weather Card
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          Row(
                            children: const [
                              Icon(Icons.wb_sunny, color: Colors.yellow, size: 30),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "34°C · Punjab",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Clear · Good for field work",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),

                          Row(
                            children: const [
                              WeatherItem(icon: Icons.water_drop, value: "62%"),
                              SizedBox(width: 15),
                              WeatherItem(icon: Icons.air, value: "12km/h"),
                              SizedBox(width: 15),
                              WeatherItem(icon: Icons.thermostat, value: "37°"),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [

                    /// QUICK ACTION CARDS
                    Row(
                      children: const [
                        Expanded(child: QuickCard(
                          title: "Soil Test",
                          subtitle: "Analyze nutrients & pH",
                          icon: Icons.science,
                          color: Colors.orange,
                        )),
                        SizedBox(width: 12),
                        Expanded(child: QuickCard(
                          title: "Crop Scan",
                          subtitle: "Detect pest & disease",
                          icon: Icons.document_scanner,
                          color: Colors.green,
                        )),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// AI ALERTS
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "⚡ AI Alerts",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "2 new",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 10),

                          AlertCard(
                            color: Colors.orange.shade100,
                            text:
                                "Low nitrogen in Field A — apply urea fertilizer within 3 days.",
                          ),

                          const SizedBox(height: 8),

                          AlertCard(
                            color: Colors.red.shade100,
                            text:
                                "Leaf rust risk high in your wheat crop — scan immediately.",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// MY FIELDS
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "My Fields",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Manage",
                                style: TextStyle(
                                  color: Colors.green,
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 15),

                          FieldCard(
                            name: "Field A",
                            crop: "Wheat · 5 acres",
                            soilValue: 0.62,
                            cropValue: 0.38,
                          ),

                          const SizedBox(height: 12),

                          FieldCard(
                            name: "Field B",
                            crop: "Rice · 3.5 acres",
                            soilValue: 0.88,
                            cropValue: 0.91,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// STATS ROW
                    Row(
                      children: const [
                        Expanded(child: StatCard(
                          icon: Icons.science,
                          iconColor: Colors.orange,
                          value: "12",
                          label: "Soil Tests",
                        )),
                        SizedBox(width: 12),
                        Expanded(child: StatCard(
                          icon: Icons.document_scanner,
                          iconColor: Colors.green,
                          value: "8",
                          label: "Crop Scans",
                        )),
                        SizedBox(width: 12),
                        Expanded(child: StatCard(
                          icon: Icons.check_circle_outline,
                          iconColor: Colors.blue,
                          value: "6",
                          label: "Issues Fixed",
                        )),
                      ],
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class QuickCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const QuickCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final Color color;
  final String text;

  const AlertCard({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}

class FieldCard extends StatelessWidget {
  final String name;
  final String crop;
  final double soilValue;
  final double cropValue;

  const FieldCard({
    super.key,
    required this.name,
    required this.crop,
    required this.soilValue,
    required this.cropValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [
            const Icon(Icons.eco, color: Colors.green),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(crop, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            )
          ],
        ),

        const SizedBox(height: 10),

        const Text("Soil"),
        LinearProgressIndicator(
          value: soilValue,
          color: Colors.orange,
          backgroundColor: Colors.grey.shade200,
        ),

        const SizedBox(height: 6),

        const Text("Crop"),
        LinearProgressIndicator(
          value: cropValue,
          color: Colors.red,
          backgroundColor: Colors.grey.shade200,
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class WeatherItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const WeatherItem({super.key, required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        )
      ],
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.science), label: "Soil Test"),
        BottomNavigationBarItem(icon: Icon(Icons.eco), label: "Crop"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
      ],
    );
  }
}