# Movie Audition App - Color Scheme System

## Overview

This document explains how to use and modify the color scheme system in the Movie Audition app. The system provides a centralized way to manage colors throughout the application, making it easy to change the entire app's appearance by modifying just one file.

## Files

### 1. `lib/util/app_colors.dart`

This is the main color scheme file. All colors used in the application are defined here.

#### Primary Colors
- `primary`: Main brand color (Deep blue-grey)
- `secondary`: Secondary brand color (Peach)
- `accent`: Accent color (Red)

#### Background Colors
- `background`: Main background color
- `cardBackground`: Background for cards and containers
- `scaffoldBackground`: Scaffold background color

#### Text Colors
- `textPrimary`: Primary text color
- `textSecondary`: Secondary text color
- `textDisabled`: Disabled text color
- `textError`: Error text color

#### Border Colors
- `border`: Default border color
- `borderFocused`: Focused border color
- `borderError`: Error border color

#### Status Colors
- `success`: Success state color
- `warning`: Warning state color
- `error`: Error state color

#### Button Colors
- `buttonPrimaryStart`: Primary button gradient start
- `buttonPrimaryEnd`: Primary button gradient end
- `buttonSecondary`: Secondary button color

#### Gradients
- `primaryGradient`: Main gradient used for buttons and UI elements

### 2. `lib/util/app_theme.dart`

This file defines the app's theme using the colors from `app_colors.dart`. It includes:
- Light theme
- Dark theme
- Text styles
- Input decoration themes
- Button themes

## How to Use

### Using Colors in Components

To use colors in your components, import the AppColors file:

```dart
import '../util/app_colors.dart';

// Then use colors like this:
Container(
  color: AppColors.primary,
  child: Text(
    'Hello World',
    style: TextStyle(color: AppColors.textPrimary),
  ),
)
```

### Using Themes

The app automatically uses the themes defined in `app_theme.dart`. You don't need to do anything special to use them.

## How to Modify Colors

To change the app's color scheme:

1. Open `lib/util/app_colors.dart`
2. Modify the color values as needed
3. Save the file
4. The changes will automatically apply throughout the app

### Example: Changing the Primary Color

To change the primary color from blue-grey to purple:

```dart
// Before
static const Color primary = Color(0xFF383950); // Deep blue-grey

// After
static const Color primary = Color(0xFF6A0DAD); // Purple
```

## Best Practices

1. **Always use AppColors**: Never use hardcoded color values in components
2. **Semantic naming**: Use semantic names that describe the purpose of the color
3. **Consistency**: Maintain consistency by using the same colors for similar purposes
4. **Accessibility**: Ensure sufficient contrast between text and background colors

## Adding New Colors

To add new colors to the scheme:

1. Add the new color constant to `app_colors.dart`:

```dart
static const Color newColor = Color(0xFF123456);
```

2. Use the new color in your components:

```dart
Text('New Color Text', style: TextStyle(color: AppColors.newColor))
```

## Theme Customization

To customize the theme further:

1. Modify the `app_theme.dart` file
2. Adjust text styles, input decorations, or button themes as needed
3. The changes will apply throughout the app

## Testing Color Changes

After making color changes:

1. Run the app to see the changes
2. Check all screens to ensure the colors look good together
3. Verify that text is still readable and accessible
4. Test both light and dark modes if applicable

## Troubleshooting

### Colors Not Updating

If colors aren't updating after changes:

1. Make sure you saved the `app_colors.dart` file
2. Perform a hot restart (not just hot reload)
3. Check that you're importing `app_colors.dart` correctly
4. Verify that you're using `AppColors.colorName` and not hardcoded values

### Import Issues

If you get import errors:

1. Make sure the path to `app_colors.dart` is correct
2. Check that the file exists in `lib/util/`
3. Ensure you're using relative imports (starting with `../` or `./`)