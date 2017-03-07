import GPUImage
import QuartzCore

let filterOperations: Array<FilterOperationInterface> = [
    FilterOperation (
        filter:{StretchDistortion()},
        listName:"Stretch",
        titleName:"Stretch",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    // TODO: Poisson blend
]
