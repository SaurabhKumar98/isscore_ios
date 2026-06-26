import 'package:firstedu/data/models/event_models.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/view/event_view/event_card.dart';
import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
final events = [
  EventModel(
    title: "All India Essay Championship",
    description: "Topic: The Role of AI in Future Education.",
    participants: "342",
    date: "Ends in 2 days",
    status: "LIVE",
    category: "Writing",
    type: EventType.written,
    icon: Icons.edit,
    iconBg: const Color(0xFFE3F2FD),
  ),
  EventModel(
    title: "Voice of Schools: Singing",
    description: "Submit 2-minute classical song.",
    participants: "210",
    date: "Ends in 2 days",
    status: "REGISTRATION OPEN",
    category: "Music",
    type: EventType.video,
    icon: Icons.music_note,
    iconBg: const Color(0xFFE8F5E9),
  ),
];


    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        slivers: [

          const CustomSliverAppBar(
            title: "Live Competitions",
            subtitle: "Participate in real-time events and win accolades.",
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => EventCard(data: events[index]),
                childCount: events.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
