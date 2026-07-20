import 'package:auto_size_text/auto_size_text.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewComponents/parts/edgeLines.dart';
import 'package:clientapp/viewmodels/navigationVM.dart';
import 'package:clientapp/viewmodels/venuesVM.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PanelVenueList extends StatefulWidget {
  final VenuesVM vm;
  final void Function(Venue) onVenueSelect;

  const PanelVenueList(this.vm, this.onVenueSelect, {super.key});

  @override
  State<PanelVenueList> createState() => _PanelVenueListState();
}

class _PanelVenueListState extends State<PanelVenueList> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.colors.primary,
            borderRadius: BorderRadius.circular(10),
          ),

          child: ListView(
            padding: EdgeInsets.all(0),
            children: [
              for (Destination venue in widget.vm.nearbyDestinations)
                VenueListItem(
                  selected: widget.vm.nodeInFocus == venue,
                  onSelect: widget.onVenueSelect,
                  venue: venue as Venue,
                ),
            ],
          ),
        );
      },
    );
  }
}

class VenueListItem extends StatelessWidget {
  const VenueListItem({
    super.key,
    required this.venue,
    required this.onSelect,
    required this.selected,
  });

  final void Function(Venue) onSelect;
  final Venue venue;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.colors.secondary,
        border: Border.all(
          color: selected ? AppTheme.colors.accent : Colors.transparent,
          width: selected ? 5 : 0,
        ),
      ),
      child: IconButton(
        onPressed: () => onSelect(venue),
        padding: EdgeInsets.all(0),
        icon: AutoSizeText(
          venue.name,
          maxLines: 1,
          textAlign: TextAlign.center,
          minFontSize: Defaults.autoTextMin,
          maxFontSize: Defaults.autoTextMax,
          style: TextStyle(color: AppTheme.colors.neutral),
        ),
      ),
    );
  }
}
